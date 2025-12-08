# Date Finder

Aplicativo Flutter para encontrar e avaliar lugares para encontros, seguindo o padrão MVC.

## Funcionalidades

- ✅ Sistema de login e cadastro de usuários (via servidor externo)
- ✅ Recuperação de senha por email
- ✅ Mapa interativo com pins dos lugares avaliados
- ✅ Adicionar novos lugares com autocomplete do Google Places
- ✅ Visualizar minhas avaliações
- ✅ Encontrar lugares próximos com rotas no mapa
- ✅ Maior precisão na localização dos pins

## Configuração

### 1. Configurar o Servidor de Autenticação

O aplicativo usa um servidor Node.js separado para autenticação. O servidor está localizado em `../date_finder_server/`.

1. Navegue até a pasta do servidor:
```bash
cd ../date_finder_server
```

2. Instale as dependências:
```bash
npm install
```

3. Configure as variáveis de ambiente:
```bash
cp .env.example .env
```

Edite o arquivo `.env` com suas configurações:
- `SMTP_USER`: Seu email (Gmail)
- `SMTP_PASS`: App Password do Gmail (crie em https://myaccount.google.com/apppasswords)
- `JWT_SECRET`: Uma chave secreta para JWT
- `PORT`: Porta do servidor (padrão: 3000)

4. Inicie o servidor:
```bash
npm start
# ou para desenvolvimento com auto-reload:
npm run dev
```

O servidor estará disponível em `http://localhost:3000`

**Importante**: Para dispositivos físicos, você precisará alterar a URL no arquivo `lib/services/api_service.dart` para o IP da sua máquina na rede local (ex: `http://192.168.1.X:3000/api`). Para emulador Android, use `http://10.0.2.2:3000/api`.

### 2. Instalar dependências do Flutter

```bash
flutter pub get
```

### 3. Configurar API do Google Places e Google Maps

Para usar o autocomplete de lugares e os mapas, você precisa:

1. Obter uma chave da API do Google (que funciona para Maps e Places):
   - Acesse o [Google Cloud Console](https://console.cloud.google.com/)
   - Crie um novo projeto ou selecione um existente
   - Ative as APIs "Maps SDK for Android" e "Places API"
   - Crie uma chave de API

2. Adicionar a chave no arquivo `android/local.properties`:
   - Abra o arquivo `android/local.properties`
   - Adicione ou atualize a linha com sua chave:

```
GOOGLE_MAPS_API_KEY=SUA_CHAVE_AQUI
```

A mesma chave será usada tanto para o Google Maps quanto para o Google Places API.

### 4. Configurar Google Maps (Android)

A chave do Google Maps já está configurada automaticamente através do arquivo `local.properties`. O build.gradle.kts lê a chave e a passa para o AndroidManifest.xml automaticamente.

### 5. Executar o aplicativo

**Certifique-se de que o servidor de autenticação está rodando antes de iniciar o app!**

```bash
flutter run
```

```bash
flutter run
```

## Estrutura do Projeto (MVC)

```
lib/
├── controllers/      # Controllers (lógica de negócio)
│   ├── auth_controller.dart
│   └── date_spot_controller.dart
├── models/           # Models (dados)
│   ├── date_spot_model.dart
│   └── user_model.dart
├── views/            # Views (interface)
│   ├── home_page.dart
│   ├── form_page.dart
│   ├── login_page.dart
│   ├── register_page.dart
│   ├── my_reviews_page.dart
│   └── nearby_page.dart
├── database/         # Banco de dados
│   └── db_helper.dart
└── services/         # Serviços externos
    ├── api_service.dart
    └── places_service.dart
```

## Funcionalidades Detalhadas

### Login e Cadastro
- Sistema de autenticação via servidor Node.js
- Validação de formulários
- Tokens JWT para autenticação
- Recuperação de senha por email
- Senhas hasheadas com bcrypt

### Mapa Principal
- Visualização de todos os lugares avaliados
- Pins com maior precisão
- Navegação para outras telas

### Adicionar Novo Lugar
- Autocomplete com Google Places API
- Seleção de data e avaliação
- Notas sobre a experiência

### Minhas Avaliações
- Lista de todas as avaliações do usuário
- Opção de excluir avaliações
- Visualização detalhada

### Próximos a Mim
- Lugares próximos à localização atual
- Traçar rotas através do Google Maps
- Filtro de distância (até 10km)

## Dependências Principais

- `google_maps_flutter`: Mapas interativos
- `geolocator`: Localização do usuário
- `sqflite`: Banco de dados local
- `http`: Requisições HTTP para API e Google Places
- `url_launcher`: Abrir rotas no Google Maps
- `shared_preferences`: Armazenar tokens de autenticação

## Estrutura do Servidor

O servidor de autenticação (`../date_finder_server/`) inclui:

- **Endpoints**:
  - `POST /api/register` - Registrar novo usuário
  - `POST /api/login` - Fazer login
  - `POST /api/forgot-password` - Solicitar recuperação de senha
  - `POST /api/reset-password` - Redefinir senha com token
  - `GET /api/verify-reset-token/:token` - Verificar token de reset

- **Segurança**:
  - Senhas hasheadas com bcrypt
  - Tokens JWT para autenticação
  - Tokens de reset expiram em 1 hora
  - Validação de entrada

## Notas

- O servidor de autenticação deve estar rodando antes de usar o app
- Para dispositivos físicos, configure o IP correto em `lib/services/api_service.dart`
- É necessário configurar a chave da API do Google Places para usar o autocomplete
- O aplicativo requer permissões de localização para funcionar corretamente
- Para usar Gmail, você precisa criar uma "App Password" em vez da senha normal
