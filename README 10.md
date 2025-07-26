# RDS Module

Універсальний Terraform модуль для створення Amazon RDS інстансів або Aurora кластерів з автоматичним налаштуванням всіх необхідних ресурсів.

## Особливості

- ✅ Підтримка як Aurora кластерів, так і звичайних RDS інстансів
- ✅ Автоматичне створення DB Subnet Group
- ✅ Автоматичне створення Security Group з налаштованими правилами
- ✅ Автоматичне створення Parameter Group з оптимальними параметрами
- ✅ Підтримка Aurora Serverless
- ✅ Налаштування Performance Insights та Enhanced Monitoring
- ✅ Гнучке налаштування через змінні
- ✅ Універсальні outputs для обох типів БД

## Використання

### Основний приклад (Regular RDS)

```hcl
module "rds" {
  source = "./modules/rds"

  # Основні налаштування
  use_aurora   = false
  project_name = "myproject"
  environment  = "prod"

  # Конфігурація бази даних
  engine         = "postgres"
  engine_version = "14.9"
  instance_class = "db.t3.micro"
  
  # Креденшели
  db_name  = "myapp"
  username = "dbadmin"
  password = "super-secure-password"

  # Мережеві налаштування
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  allowed_cidr_blocks = ["10.0.0.0/8"]
  # або
  allowed_security_groups = [aws_security_group.app.id]

  # Додаткові налаштування
  allocated_storage = 20
  multi_az         = true
  publicly_accessible = false

  tags = {
    Environment = "prod"
    Project     = "myproject"
  }
}
```

### Aurora Cluster

```hcl
module "aurora" {
  source = "./modules/rds"

  # Aurora налаштування
  use_aurora = true
  project_name = "myproject"
  environment  = "prod"

  # Конфігурація Aurora
  engine         = "aurora-postgresql"
  engine_version = "14.9"
  instance_class = "db.r6g.large"
  
  # Кластер налаштування
  aurora_cluster_size = 2
  
  # Креденшели
  db_name  = "myapp"
  username = "dbadmin"
  password = var.db_password

  # Мережеві налаштування
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  allowed_security_groups = [
    aws_security_group.app.id,
    aws_security_group.admin.id
  ]

  tags = local.common_tags
}
```

### Aurora Serverless

```hcl
module "aurora_serverless" {
  source = "./modules/rds"

  use_aurora = true
  project_name = "myproject"
  environment  = "dev"

  # Serverless налаштування
  engine            = "aurora-mysql"
  engine_version    = "8.0.mysql_aurora.3.02.0"
  aurora_serverless = true
  aurora_min_capacity = 0.5
  aurora_max_capacity = 4

  db_name  = "testdb"
  username = "admin"
  password = var.db_password

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  allowed_cidr_blocks = ["10.0.0.0/16"]

  tags = {
    Environment = "dev"
    AutoPause   = "enabled"
  }
}
```

## Змінні

### Обов'язкові змінні

| Змінна | Тип | Опис |
|--------|-----|------|
| `password` | `string` | Пароль master користувача (sensitive) |
| `vpc_id` | `string` | ID VPC для розміщення RDS |
| `subnet_ids` | `list(string)` | Список ID підмереж для DB subnet group |
| `project_name` | `string` | Назва проєкту для іменування ресурсів |

### Основні налаштування

| Змінна | Тип | За замовчуванням | Опис |
|--------|-----|------------------|------|
| `use_aurora` | `bool` | `false` | Використовувати Aurora кластер замість RDS |
| `engine` | `string` | `"mysql"` | Тип БД (mysql, postgres, aurora-mysql, aurora-postgresql) |
| `engine_version` | `string` | `"8.0"` | Версія двигуна БД |
| `instance_class` | `string` | `"db.t3.micro"` | Клас інстансу |
| `environment` | `string` | `"dev"` | Середовище розгортання |

### Конфігурація БД

| Змінна | Тип | За замовчуванням | Опис |
|--------|-----|------------------|------|
| `db_name` | `string` | `"mydb"` | Назва бази даних |
| `username` | `string` | `"admin"` | Master користувач |
| `allocated_storage` | `number` | `20` | Розмір сховища в ГБ (тільки для RDS) |
| `max_allocated_storage` | `number` | `100` | Максимальний розмір для autoscaling |
| `storage_type` | `string` | `"gp2"` | Тип сховища (gp2, gp3, io1) |
| `multi_az` | `bool` | `false` | Увімкнути Multi-AZ |
| `publicly_accessible` | `bool` | `false` | Публічний доступ |

### Мережеві налаштування

| Змінна | Тип | За замовчуванням | Опис |
|--------|-----|------------------|------|
| `allowed_cidr_blocks` | `list(string)` | `[]` | CIDR блоки з доступом до БД |
| `allowed_security_groups` | `list(string)` | `[]` | Security groups з доступом до БД |

### Aurora специфічні

| Змінна | Тип | За замовчуванням | Опис |
|--------|-----|------------------|------|
| `aurora_cluster_size` | `number` | `1` | Кількість інстансів в кластері |
| `aurora_serverless` | `bool` | `false` | Увімкнути Serverless режим |
| `aurora_min_capacity` | `number` | `0.5` | Мін. потужність Serverless |
| `aurora_max_capacity` | `number` | `1` | Макс. потужність Serverless |

### Резервні копії

| Змінна | Тип | За замовчуванням | Опис |
|--------|-----|------------------|------|
| `backup_retention_period` | `number` | `7` | Період зберігання бекапів (дні) |
| `backup_window` | `string` | `"03:00-04:00"` | Вікно для бекапів |
| `maintenance_window` | `string` | `"sun:04:00-sun:05:00"` | Вікно для обслуговування |

## Outputs

### Універсальні (працюють для Aurora і RDS)

- `endpoint` - Основний endpoint для підключення
- `port` - Порт БД
- `database_name` - Назва бази даних
- `username` - Master користувач
- `engine` - Тип двигуна БД
- `engine_version` - Версія двигуна

### RDS специфічні

- `db_instance_endpoint` - Endpoint RDS інстансу
- `db_instance_address` - Адреса RDS інстансу
- `db_instance_id` - ID RDS інстансу
- `db_instance_arn` - ARN RDS інстансу

### Aurora специфічні

- `aurora_cluster_endpoint` - Endpoint Aurora кластера (writer)
- `aurora_cluster_reader_endpoint` - Read-only endpoint
- `aurora_cluster_id` - ID Aurora кластера
- `aurora_cluster_arn` - ARN Aurora кластера
- `aurora_instance_endpoints` - Endpoints всіх інстансів

### Допоміжні

- `db_subnet_group_name` - Назва DB subnet group
- `security_group_id` - ID security group
- `parameter_group_name` - Назва parameter group

## Як змінити тип БД

### Перехід з MySQL на PostgreSQL

```hcl
module "rds" {
  # ...інші параметри...
  
  engine         = "postgres"     # було "mysql"
  engine_version = "14.9"         # було "8.0"
  
  # При необхідності змініть інші параметри
  db_name = "myapp_pg"
}
```

### Перехід з RDS на Aurora

```hcl
module "rds" {
  # ...інші параметри...
  
  use_aurora     = true           # було false
  engine         = "aurora-mysql" # було "mysql"
  instance_class = "db.r6g.large" # Aurora потребує інший клас
  
  # Налаштування кластера
  aurora_cluster_size = 2
  
  # Видаліть RDS-специфічні параметри
  # allocated_storage = 20  # <-- видалити
  # multi_az = true         # <-- видалити
}
```

### Увімкнення Serverless

```hcl
module "aurora" {
  # ...інші параметри...
  
  use_aurora        = true
  aurora_serverless = true
  aurora_min_capacity = 0.5
  aurora_max_capacity = 16
  
  # Видаліть instance_class та aurora_cluster_size
  # instance_class = "..."      # <-- не потрібно для Serverless
  # aurora_cluster_size = 2     # <-- не потрібно для Serverless
}
```

## Підтримувані типи БД

### Regular RDS
- **MySQL**: `mysql` + версії 5.7, 8.0
- **PostgreSQL**: `postgres` + версії 12, 13, 14, 15

### Aurora
- **Aurora MySQL**: `aurora-mysql` + версії 5.7, 8.0
- **Aurora PostgreSQL**: `aurora-postgresql` + версії 12, 13, 14

## Автоматичні параметри

Модуль автоматично налаштовує оптимальні параметри БД:

### MySQL/Aurora MySQL
- `max_connections = 1000`
- `innodb_buffer_pool_size = {DBInstanceClassMemory*3/4}`

### PostgreSQL/Aurora PostgreSQL
- `max_connections = 100`
- `shared_preload_libraries = pg_stat_statements`
- `log_statement = all`
- `work_mem = 4096`

## Безпека

- Усі БД створюються з увімкненим шифруванням
- Performance Insights увімкнено за замовчуванням
- Enhanced Monitoring налаштовано автоматично
- Security Group налаштовується автоматично з мінімальними правами

## Приклад використання з output

```hcl
# Створення RDS
module "database" {
  source = "./modules/rds"
  # ...конфігурація...
}

# Використання в додатку
resource "kubernetes_secret" "db_credentials" {
  metadata {
    name = "db-credentials"
  }
  
  data = {
    host     = module.database.endpoint
    port     = module.database.port
    database = module.database.database_name
    username = module.database.username
    password = var.db_password
  }
}
```
