# Tech Challenge - SOAT1 - Grupo 13 - Terraform para criação da infra </h1>

![GitHub](https://img.shields.io/github/license/dropbox/dropbox-sdk-java)

# Resumo do projeto

O objetivo central deste projeto Terraform é estabelecer a infraestrutura na AWS para nosso fictício controle de pontos. O projeto compreende vários módulos cuidadosamente projetados para atender às necessidades da aplicação.

**Módulo de Rede**

No módulo de rede, criamos toda a infraestrutura necessária para a rede, incluindo:

- **VPC (Virtual Private Cloud)**: A VPC é o alicerce da nossa rede, permitindo o isolamento e a segmentação dos recursos.
- **Subnets Públicas e Privadas**: Para alocar recursos que exigem diferentes níveis de acessibilidade.
- **Internet Gateway**: Facilita a comunicação com a Internet a partir da VPC.
- **Subnet Group para o Banco de Dados**: Uma segmentação específica para o banco de dados, garantindo sua segurança e desempenho.
- **Security Group da VPC**: As regras de segurança para proteger a VPC.
- **Route Tables**: Responsáveis pelo encaminhamento de tráfego entre as subnets.

**Módulo de Banco de Dados**

Este módulo é responsável por configurar o ambiente de banco de dados, que inclui:

- **Security Group do RDS**: Regras de segurança para o banco de dados.
- **RDS com PostgreSQL**: Configuração do banco de dados PostgreSQL e sua replica de leitura.
- **DynamoDB**: Nosso banco de dados NoSQL, que oferece alta escalabilidade e desempenho.

**Módulo lambda**

Aqui criamos uma lambda function que serve como lambda authorizer para nosso api gateway

**Módulo S3**

Aqui criamos um bucket S3 dedicado para armazenar o arquivo ZIP do Lambda, facilitando o armazenamento e o acesso a recursos da aplicação.

**Módulo Secrets Manager**

O módulo Secrets Manager é usado para armazenar informações sensíveis de forma segura, como chaves e credenciais.

**Módulo ALB (Application Load Balancer)**

O Application Load Balancer é essencial para distribuir o tráfego de entrada entre instâncias do ECS (Elastic Container Service) e inclui:

- **Load Balancer**: Responsável por distribuir o tráfego de entrada.
- **Listener e Target Group**: Configurações para encaminhar o tráfego para as instâncias corretas.
- **Security Groups**: As regras de segurança para proteger o Load Balancer.

**Módulo ECS (Elastic Container Service)**

O módulo ECS é responsável por gerenciar a execução de nossa aplicação em containers, e inclui:

- **Cluster**: O ambiente para execução de containers.
- **Políticas e Funções (Roles)**: Permissões e funções necessárias para as operações do ECS.
- **Definição de Tarefa (Task Definition)**: Configurações para a execução da aplicação.
- **Serviço**: Responsável por manter as instâncias da aplicação em execução.
- **ASG(Auto Scaling Group)**: Responsável por escalar horizontalmente nossa aplicação em horarios de pico.

Estamos à disposição para qualquer dúvida ou sugestão que você possa ter. Agradecemos pelo seu interesse em nosso projeto!

License: [MIT](License.txt)

# Desenho da infraestrutura

![Infraestrutura na AWS](<Infra.png>)

# ✔️ Tecnologias utilizadas

- ``Terraform``


# Autores

| [<img src="https://avatars.githubusercontent.com/u/28829303?s=400&v=4" width=115><br><sub>Christian Melo</sub>](https://github.com/christiandmelo) |  [<img src="https://avatars.githubusercontent.com/u/89987201?v=4" width=115><br><sub>Luiz Soh</sub>](https://github.com/luiz-soh) |  [<img src="https://avatars.githubusercontent.com/u/21027037?v=4" width=115><br><sub>Wagner Neves</sub>](https://github.com/nevesw) |  [<img src="https://avatars.githubusercontent.com/u/34692183?v=4" width=115><br><sub>Mateus Bernardi Marcato</sub>](https://github.com/xXMateus97Xx) |
| :---: | :---: | :---: | :---: |
