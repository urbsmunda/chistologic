# ChistoLogic – руководство разработчика

> **TL;DR**
> 1. Установите `yc`, `terraform >=1.5`, `helm`, `kubectl`.
> 2. Заполните Secrets в GitHub (Settings → Secrets → Actions):
>    * `YANDEX_CLOUD_ID`, `YANDEX_FOLDER_ID`
>    * `OBJECT_STORAGE_ACCESS_KEY`, `OBJECT_STORAGE_SECRET_KEY`
>    * `TELEGRAM_BOT_TOKEN_KMS_SECRET_ID`
> 3. Нажмите **Run workflow** → `Terraform Deploy` – через ≈5 минут инфраструктура готова.

---

## 1. Предварительные требования

| Инструмент | Версия | Установка |
|------------|--------|-----------|
| Yandex CLI | ≥ 0.123 | `curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh \| bash` |
| Terraform  | ≥ 1.5  | `brew install terraform` / Chocolatey / официальный архив |
| kubectl    | ≥ 1.29 | `brew install kubectl` |
| Helm       | ≥ 3.14 | `brew install helm` |
| jq, openssl| —      | любой пакетный менеджер |

---

## 2. Настройка секретов

### 2.1 Yandex Cloud (OIDC)

1. В консоли YC создайте сервис-аккаунт **`chistologic-ci`**.
2. Дайте роли:
   * `editor` (минимально для PoC) **или** набор least-privilege (см. таблицу ниже).
3. В разделе «Federations → GitHub» включите **OIDC-федерацию**.
4. Сохраните `cloud_id`, `folder_id` → добавьте в Secrets.

| Ресурс                    | Роль                                  |
|---------------------------|---------------------------------------|
| Object Storage (bucket)   | `storage.objectAdmin`<br>`storage.viewer` |
| Container Registry        | `container-registry.images.pusher`   |
| Kubernetes cluster        | `k8s.clusters.agent`                 |
| IAM                       | `iam.serviceAccounts.user`           |

### 2.2 Object Storage backend

* Создайте бакет **`chistologic-tfstate`** (версионирование *on*).
* Сгенерируйте статический ключ → сохраните в Secrets
  `OBJECT_STORAGE_ACCESS_KEY`, `OBJECT_STORAGE_SECRET_KEY`.

---

## 3. CI/CD процесс

```mermaid
graph LR
A[push / PR] --> B(fmt & validate)
B --> C(plan)
C -->|main| D(apply)
C -->|PR| E(artifacts)
