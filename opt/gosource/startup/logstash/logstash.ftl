input {
# Docker logs are all in one directory so directly fetch them
  s3 {
    bucket => "${LOGS}"
    prefix => "DOCKERLogs/pending"
    region => "${REGION}"
    codec => json
    type => docker
    delete => true
  }
  
# AWS elb logs - they stored per day so assume they are cached locally
  file {
    path => "${ROOT}/cache/awslogs/elasticloadbalancing/**/*.log"
    sincedb_path => "${ROOT}/cache/awslogs/.since_db_elb"
    start_position => "beginning"
    type => elb
  }
}

filter {
# Detect known formats
# ELB format copied from https://github.com/logstash-plugins/logstash-patterns-core/blob/master/patterns/grok-patterns
# and useragent/SSL details added. @metadata being used for timestamp and useragent data.
  grok {
     patterns_dir => "${ROOT}/patterns"
     match => ["message", "%{GS_ELB_ACCESS_LOG}"]
  }

# Convert various timestamp formats to @timestamp
  if [time] {
    date {
      match => [ "time", "ISO8601" ]
    }
    mutate {
      remove_field => [ "time" ]
    }
  }
  if [@metadata][timestamp] {
    date {
      match => [ "[@metadata][timestamp]", "ISO8601" ]
    }
  }
  
# Convert fluentd docker log driver log field to message
  if [log] {
    mutate {
      add_field => { "message" => "%{[log]}" }
      remove_field => [ "log" ]
    }
  }
  
# Analyse useragent if present
  if [@metadata][useragent] {
    useragent {
      target => "useragent"
      source => "[@metadata][useragent]"
      add_field => { "[useragent][raw]" => "%{[@metadata][useragent]}" }
    }
  }

# Analyse source IP address if present
# Database from http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
  if [client_ip] {
    geoip {
      source => "client_ip"
      database => "${ROOT}/geoip/GeoLiteCity.dat"
    }
  }

# Add default component breakdown if not present
  if ![project] {
    mutate {
      add_field => { "project" => "${PROJECT}" }
    }
  }
  if ![container] {
    mutate {
      add_field => { "container" => "${CONTAINER}" }
    }
  }
  if ![tier] {
    mutate {
      add_field => { "tier" => "" }
    }
  }
  if ![component] {
    mutate {
      add_field => { "component" => "" }
    }
  }
  if ![subcomponent] {
    mutate {
      add_field => { "subcomponent" => "" }
    }
  }
  
# Try and determine tier/component/subcomponent from the data
  grok {
     overwrite => ["project", "container", "tier", "component", "subcomponent" ]
     tag_on_failure => []
     match => [
        "tag", "^docker.(?<project>[a-zA-Z0-9]+)\.(?<container>[a-zA-Z0-9]+)\.(?<tier>[a-zA-Z0-9]+)\.(?<component>[a-zA-Z0-9]+)\.(?<subcomponent>[a-zA-Z0-9]+)$",
        "container_name", ".*-(?<tier>[a-zA-Z0-9]+)-(?<component>[a-zA-Z0-9]+)-(?<subcomponent>[a-zA-Z0-9]+)-[0-9a-fA-F]+$",
        "container_name", "ecs-(?<subcomponent>agent)$",
        "elb", "^(?<project>[a-zA-Z0-9]+)-(?<container>[a-zA-Z0-9]+)-(?<tier>[a-zA-Z0-9]+)-(?<component>[a-zA-Z0-9]+)$"
     ]
  }
  
# Finally clean up any extraneous fields
  if [type] == "elb" {
    mutate {
      remove_field => [ "path", "host" ]
    }
  }
}

output {
  elasticsearch {
    hosts => ["${ES}"]
    index => "logs-%{+YYYY.MM.dd}"
    manage_template => true
    template => "${ROOT}/logs_template.json"
    template_name => "logs"
    template_overwrite => true
  }
}



