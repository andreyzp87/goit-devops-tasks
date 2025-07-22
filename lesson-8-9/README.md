# Lesson 8-9 - Complete CI/CD Pipeline with Jenkins + Argo CD + Kubernetes

Це завдання включає створення повного CI/CD процесу з використанням Jenkins + Helm + Terraform + Argo CD, який автоматично збирає Docker-образи, публікує їх в Amazon ECR, оновлює Helm charts та синхронізує застосунки у кластері.

## Структура проєкту

```
lesson-8-9/
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf               # Загальні виводи ресурсів
├── modules/                 # Каталог з усіма модулями
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   ├── vpc/                 # Модуль для VPC
│   ├── ecr/                 # Модуль для ECR
│   ├── eks/                 # Модуль для Kubernetes кластера
│   │   ├── eks.tf
│   │   ├── aws_ebs_csi_driver.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── jenkins/             # Модуль для Jenkins через Helm
│   │   ├── jenkins.tf       # Helm release та IAM roles
│   │   ├── variables.tf     # Змінні для Jenkins
│   │   ├── values.yaml      # Конфігурація Jenkins
│   │   └── outputs.tf       # Виводи Jenkins
│   └── argo_cd/             # Модуль для Argo CD через Helm
│       ├── argo_cd.tf       # Helm release для Argo CD
│       ├── variables.tf     # Змінні для Argo CD
│       ├── values.yaml      # Конфігурація Argo CD
│       ├── outputs.tf       # Виводи Argo CD
│       └── charts/          # Helm chart для Argo CD Applications
│           ├── Chart.yaml
│           ├── values.yaml
│           └── templates/
│               ├── application.yaml
│               └── repository.yaml
└── charts/
    └── django-app/          # Helm chart для Django застосунку
        ├── templates/
        │   ├── deployment.yaml
        │   ├── service.yaml
        │   ├── configmap.yaml
        │   └── hpa.yaml
        ├── Chart.yaml
        └── values.yaml
```

## CI/CD Процес

### 1. Jenkins Pipeline
- **Автоматичне збирання** Docker образів з Dockerfile
- **Публікація** образів до Amazon ECR
- **Оновлення** тегів у Helm chart values.yaml
- **Commit & Push** змін до Git репозиторію

### 2. Argo CD GitOps
- **Моніторинг** Git репозиторію на зміни
- **Автоматична синхронізація** застосунків
- **Безперервне розгортання** оновлених версій

## Кроки розгортання

### 1. Ініціалізація та застосування Terraform

```bash
# Перейти до каталогу lesson-8-9
cd lesson-8-9

# Ініціалізувати Terraform
terraform init

# Перевірити план
terraform plan

# Застосувати конфігурацію
terraform apply
```

### 2. Налаштування kubectl для роботи з EKS

```bash
# Отримати конфігурацію кластера
aws eks update-kubeconfig --region eu-central-1 --name lesson-9-eks-cluster

# Перевірити з'єднання з кластером
kubectl get nodes
```

### 3. Доступ до Jenkins

```bash
# Отримати Jenkins LoadBalancer URL
kubectl get services -n jenkins

# Отримати початковий пароль Jenkins
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo

# Альтернативно, використовуйте налаштований пароль: admin123
```

### 4. Налаштування Jenkins Pipeline

1. **Увійти до Jenkins** з обліковими даними admin/admin123
2. **Запустити seed-job** для створення pipeline
3. **Налаштувати GitHub credentials** (вже налаштовані через JCasC)
4. **Запустити goit-django-docker pipeline**

### 5. Доступ до Argo CD

```bash
# Отримати Argo CD LoadBalancer URL
kubectl get services -n argocd

# Отримати початковий пароль admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Увійти як admin з отриманим паролем
```

### 6. Перевірка роботи застосунку

```bash
# Перевірити Django application
kubectl get applications -n argocd
kubectl get pods -n default
kubectl get services -n default

# Отримати external IP Load Balancer Django app
kubectl get services django-app
```

## Компоненти

### EKS Кластер
- **Назва**: lesson-9-eks-cluster
- **Версія Kubernetes**: 1.28
- **Node Group**: t2.micro instances
- **Scaling**: 1-2 nodes (desired: 1)
- **OIDC Provider**: для IRSA (IAM Roles for Service Accounts)

### Jenkins
- **Namespace**: jenkins
- **Service Type**: LoadBalancer
- **Plugins**: Kubernetes, Git, Docker, Job DSL
- **Service Account**: jenkins-sa з ECR permissions
- **Kaniko**: для збирання Docker образів без Docker daemon

### Argo CD
- **Namespace**: argocd
- **Service Type**: LoadBalancer
- **GitOps Repository**: https://github.com/AndriyDmitriv/goit-devops.git
- **Auto-sync**: увімкнено
- **Self-heal**: увімкнено

### ECR Repository
- **Назва**: lesson-9-django-app
- **Сканування образів**: увімкнено

### Django Application
- **Replicas**: 2
- **Autoscaling**: 2-10 pods
- **Resources**: CPU та Memory limits
- **Service**: LoadBalancer type

## Jenkins Pipeline Workflow

1. **Trigger**: Git commit до основного репозиторію
2. **Build**: Kaniko збирає Docker образ
3. **Push**: Образ завантажується до ECR
4. **Update**: Оновлюється tag у values.yaml
5. **Commit**: Зміни комітяться до Git
6. **Sync**: Argo CD підхоплює зміни та розгортає

## Argo CD Applications

- **django-app**: Моніторить django-chart у Git репозиторії
- **Auto-sync**: Автоматично застосовує зміни
- **Self-healing**: Відновлює стан при ручних змінах

## Корисні команди

### Jenkins
```bash
# Перегляд Jenkins pods
kubectl get pods -n jenkins

# Перегляд Jenkins logs
kubectl logs -f -n jenkins deployment/jenkins

# Перегляд Jenkins service
kubectl get services -n jenkins
```

### Argo CD
```bash
# Перегляд Argo CD applications
kubectl get applications -n argocd

# Синхронізація application вручну
argocd app sync django-app

# Перегляд статусу
argocd app get django-app
```

### Django Application
```bash
# Перегляд Django pods
kubectl get pods

# Перегляд logs
kubectl logs -f deployment/django-app

# Масштабування
kubectl scale deployment django-app --replicas=3

# HPA статус
kubectl get hpa
```

## Troubleshooting

### Jenkins Issues
```bash
# Перевірка Jenkins pod logs
kubectl logs -n jenkins -l app.kubernetes.io/component=jenkins-controller

# Перевірка Service Account
kubectl get serviceaccount jenkins-sa -n jenkins -o yaml

# Перевірка IAM role annotations
kubectl describe serviceaccount jenkins-sa -n jenkins
```

### Argo CD Issues
```bash
# Перевірка Argo CD server logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server

# Перевірка application статусу
kubectl describe application django-app -n argocd

# Ручна синхронізація
kubectl patch application django-app -n argocd --type merge --patch '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'
```

## Очищення ресурсів

```bash
# Видалити Argo CD applications
kubectl delete applications --all -n argocd

# Видалити Terraform ресурси
terraform destroy
```
