terraform {
  required_version = ">= 1.10.0, < 2.0.0"
}

locals {
  services = {
    AUL = {
      name           = "classroom-service"
      level          = 1
      database_name  = "aula_db"
      valkey_enabled = true
      s3_enabled     = false
      extensions     = ["pgcrypto"]
      topics = [
        "mp.aul.aula.v1",
        "mp.aul.contenido.v1",
        "mp.aul.tarea.v1",
        "mp.aul.entrega.v1",
        "mp.aul.cuestionario.v1",
        "mp.aul.intento.v1",
        "mp.aul.anuncio.v1",
        "mp.aul.actividad.v1"
      ]
    }
    CNT = {
      name           = "content-service"
      level          = 1
      database_name  = "contenido_db"
      valkey_enabled = true
      s3_enabled     = true
      extensions     = ["pgcrypto"]
      topics         = ["mp.aul.contenido.v1"]
    }
    ASG = {
      name           = "assignment-service"
      level          = 1
      database_name  = "tareas_db"
      valkey_enabled = false
      s3_enabled     = true
      extensions     = ["pgcrypto"]
      topics = [
        "mp.aul.tarea.v1",
        "mp.aul.entrega.v1"
      ]
    }
    CUE = {
      name           = "quiz-service"
      level          = 1
      database_name  = "cuestionarios_db"
      valkey_enabled = false
      s3_enabled     = false
      extensions     = ["pgcrypto"]
      topics = [
        "mp.aul.cuestionario.v1",
        "mp.aul.intento.v1"
      ]
    }
    GRD = {
      name           = "grading-service"
      level          = 1
      database_name  = "calificaciones_db"
      valkey_enabled = false
      s3_enabled     = false
      extensions     = ["pgcrypto"]
      topics = [
        "mp.grd.libreta-datos.v1",
        "mp.aul.entrega.v1",
        "mp.aul.intento.v1"
      ]
    }
    ATT = {
      name           = "attendance-service"
      level          = 1
      database_name  = "asistencia_db"
      valkey_enabled = false
      s3_enabled     = false
      extensions     = ["pgcrypto"]
      topics         = []
    }
    ATC = {
      name           = "attendance-compliance-service"
      level          = 2
      database_name  = "cumplimiento_db"
      valkey_enabled = false
      s3_enabled     = false
      extensions     = ["pgcrypto"]
      topics         = []
    }
    ANL = {
      name           = "analytics-service"
      level          = 2
      database_name  = "analitica_db"
      valkey_enabled = false
      s3_enabled     = true
      extensions     = ["pgcrypto"]
      topics = [
        "mp.aul.aula.v1",
        "mp.aul.contenido.v1",
        "mp.aul.tarea.v1",
        "mp.aul.entrega.v1",
        "mp.aul.cuestionario.v1",
        "mp.aul.intento.v1",
        "mp.aul.anuncio.v1",
        "mp.aul.actividad.v1",
        "mp.grd.libreta-datos.v1",
        "mp.rsk.riesgo-conductual.v1",
        "mp.rsk.alerta-conductual.v1"
      ]
    }
    RPT = {
      name           = "reporting-service"
      level          = 2
      database_name  = "reportes_db"
      valkey_enabled = false
      s3_enabled     = true
      extensions     = ["pgcrypto"]
      topics         = ["mp.grd.libreta-datos.v1"]
    }
    RSK = {
      name           = "risk-service"
      level          = 2
      database_name  = "riesgo_db"
      valkey_enabled = false
      s3_enabled     = false
      extensions     = ["pgcrypto"]
      topics = [
        "mp.aul.actividad.v1",
        "mp.aul.entrega.v1",
        "mp.rsk.riesgo-conductual.v1",
        "mp.rsk.alerta-conductual.v1"
      ]
    }
  }

  topics = {
    "mp.aul.aula.v1" = {
      partitions         = 6
      replication_factor = 3
      retention_ms       = 7776000000
      cleanup_policy     = "delete"
    }
    "mp.aul.contenido.v1" = {
      partitions         = 6
      replication_factor = 3
      retention_ms       = 2592000000
      cleanup_policy     = "delete"
    }
    "mp.aul.tarea.v1" = {
      partitions         = 6
      replication_factor = 3
      retention_ms       = 2592000000
      cleanup_policy     = "delete"
    }
    "mp.aul.entrega.v1" = {
      partitions         = 6
      replication_factor = 3
      retention_ms       = 31536000000
      cleanup_policy     = "delete"
    }
    "mp.aul.cuestionario.v1" = {
      partitions         = 6
      replication_factor = 3
      retention_ms       = 2592000000
      cleanup_policy     = "delete"
    }
    "mp.aul.intento.v1" = {
      partitions         = 6
      replication_factor = 3
      retention_ms       = 2592000000
      cleanup_policy     = "delete"
    }
    "mp.aul.anuncio.v1" = {
      partitions         = 6
      replication_factor = 3
      retention_ms       = 2592000000
      cleanup_policy     = "delete"
    }
    "mp.aul.actividad.v1" = {
      partitions         = 6
      replication_factor = 3
      retention_ms       = 604800000
      cleanup_policy     = "delete"
    }
    "mp.grd.libreta-datos.v1" = {
      partitions         = 6
      replication_factor = 3
      retention_ms       = 31536000000
      cleanup_policy     = "delete"
    }
    "mp.rsk.riesgo-conductual.v1" = {
      partitions         = 6
      replication_factor = 3
      retention_ms       = 7776000000
      cleanup_policy     = "delete"
    }
    "mp.rsk.alerta-conductual.v1" = {
      partitions         = 6
      replication_factor = 3
      retention_ms       = 7776000000
      cleanup_policy     = "delete"
    }
  }
}

output "services" {
  description = "Module C service catalogue."
  value       = local.services
}

output "topics" {
  description = "Module C Kafka topic catalogue."
  value       = local.topics
}
