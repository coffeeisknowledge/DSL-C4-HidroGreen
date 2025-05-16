workspace "Plataforma HidroGreen" "Modelo C4 de la plataforma HidroGreen (Contexto, Contenedores, Componentes y Despliegue)" {

    model {
        // Personas
        agricultor    = person "Agricultor"      "Usuario principal que gestiona sus cultivos y diagnósticos desde la plataforma."

        // Sistemas Externos
        weatherApi = softwareSystem "API Meteorológica"      "Servicio externo de datos climáticos y pronósticos."    "Extern System"
        msgService = softwareSystem "Servicio de Mensajería" "Envío de SMS, email y push notifications."             "Extern System"
        niubiz     = softwareSystem "Pasarela de Pagos Niubiz" "Sistema externo para gestionar pagos y suscripciones." "Extern System"

        // Sistema Principal
        hidroGreen = softwareSystem "Plataforma HidroGreen" "Solución IA para diagnóstico temprano de enfermedades en cultivos." {
            // Persistencia
            database = container "Base de Datos HidroGreen" "Almacena usuarios, cultivos, diagnósticos, tratamientos y preferencias." "PostgreSQL" "Database"

            // Frontends
            landingPage = container "Landing Page" "Página de presentación y registro."                              "HTML, CSS, JavaScript" "Web Browser"
            webApp      = container "Aplicación Web" "Dashboard para gestión, análisis y reportes."                   "Angular, TypeScript"    "Web Application"
            mobileApp   = container "Aplicación Móvil" "App offline-first con diagnóstico y sincronización."        "React Native"           "Mobile App"

            // Infraestructura de servicio
            apiGateway  = container "API Gateway"      "Punto de entrada unificado; autentica y enruta peticiones." "Spring Cloud Gateway" "API Gateway"
            loadBalancer = container "Balanceador de Carga" "Reparte tráfico entre microservicios."                 "AWS ELB"              "Load Balancer"

            // Microservicios
            apiSecurity     = container "API de Seguridad"   "Gestiona autenticación y autorización."           "Java, Spring Boot" "API" {
                securityController = component "Security Controller" "Expone endpoints de login, registro y JWT."
                securityService    = component "Security Service"    "Lógica de autenticación y validación de tokens."
                jwtService         = component "JWT Component"       "Genera y valida JWT."
            }

            apiUsers        = container "API de Usuarios"    "CRUD de cuentas, perfiles y preferencias."        "Java, Spring Boot" "API" {
                userController   = component "User Controller"
                userService      = component "User Service"
                profileComponent = component "Profile Component"
                prefsComponent   = component "Preferences Component"
            }

            apiCrops        = container "API de Cultivos"    "Gestión de cultivos y bitácora."                 "Java, Spring Boot" "API" {
                cropsController  = component "Crops Controller"
                cropsService     = component "Crops Service"
                historyComponent = component "History Component"
            }
            
            apiSubscriptions = container "API de Suscripciones" "Gestiona suscripciones de los usuarios." "Java, Spring Boot" "API" {
                subscriptionController = component "Subscription Controller" "Exposición de endpoints para suscripción y pagos."
                subscriptionService    = component "Subscription Service"    "Lógica de manejo de suscripciones y pagos."
                paymentGatewayComponent = component "Payment Gateway Component" "Interacción con la pasarela de pagos Niubiz."
            }

            apiDiagnosis    = container "API de Diagnóstico" "Procesa imágenes y orquesta inferencia IA."      "Python, FastAPI"   "API" {
                uploadController   = component "Upload Controller"    "Recibe imágenes del frontend."
                processingService  = component "Processing Service"  "Coloca trabajos en la cola de diagnóstico."
                queueComponent     = component "Queue Component"      "Gestiona RabbitMQ para trabajos asíncronos."
                inferenceComponent = component "Inference Component"  "Consume trabajos y llama al servicio IA."
            }

            apiTreatments   = container "API de Tratamientos"  "Genera recomendaciones y lista de compras."       "Java, Spring Boot" "API" {
                treatmentController     = component "Treatment Controller"
                treatmentService        = component "Treatment Service"
                shoppingListComponent   = component "Shopping List Component"
            }

            apiSync         = container "API de Sincronización" "Manejo de sincronización offline y resolución de conflictos." "Node.js, Express" "API" {
                syncController       = component "Sync Controller"
                conflictsService     = component "Conflict Resolution Service"
            }

            apiNotifications = container "API de Notificaciones" "Envía push, email y SMS."                        "Java, Spring Boot" "API" {
                notificationController = component "Notification Controller"
                notificationService    = component "Notification Service"
                emailComponent         = component "Email Component"
                pushComponent          = component "Push Component"
                smsComponent           = component "SMS Component"
            }

            apiReports      = container "API de Reportes"    "Genera informes y exporta datos."                  "Java, Spring Boot" "API" {
                reportController  = component "Report Controller"
                reportService     = component "Report Service"
                exportComponent   = component "Export Component"
            }

            // Servicios especializados
            aiService       = container "Servicio de IA"       "Modelo de ML para detección de enfermedades."    "AWS SageMaker"    "External API"
            storageService  = container "Bucket S3"            "Almacena imágenes de cultivos para diagnóstico." "AWS S3"           "File Storage"
        }

        // Relaciones internas de componentes
        subscriptionController -> subscriptionService   "Orquesta proceso de suscripción"
        subscriptionService    -> paymentGatewayComponent "Conversa con la pasarela de pagos Niubiz"
        paymentGatewayComponent -> niubiz                  "Realiza transacciones de pago"
        subscriptionService    -> database                "Almacena datos de suscripción"
        
        securityController -> securityService       "Orquesta autenticación"
        securityService    -> jwtService            "Genera y valida JWT"
        securityService    -> database              "Consulta usuarios"

        userController     -> userService           "CRUD de usuarios"
        userService        -> database              "Persistencia de datos de usuario"

        cropsController    -> cropsService          "Operaciones CRUD de cultivos"
        cropsService       -> historyComponent      "Gestiona bitácora"
        cropsService       -> database              "Almacena eventos"

        uploadController   -> storageService        "Sube imagen para diagnóstico"        "REST/HTTPS"
        uploadController   -> processingService     "Inicia procesamiento de diagnóstico"
        processingService  -> queueComponent        "Publica trabajo"
        queueComponent     -> inferenceComponent    "Consume trabajo"
        inferenceComponent -> aiService             "Solicita inferencia"                 "REST/HTTPS"
        inferenceComponent -> database              "Guarda resultado de diagnóstico"

        treatmentController -> treatmentService     "Orquesta recomendaciones"
        treatmentService    -> shoppingListComponent "Genera lista de compras"
        treatmentService    -> database             "Almacena plan de tratamiento"

        syncController      -> conflictsService     "Resuelve conflictos offline"
        conflictsService    -> database             "Sincroniza cambios"

        notificationController -> notificationService "Orquesta envío de alertas"
        notificationService    -> emailComponent      "Email"
        notificationService    -> pushComponent       "Push"
        notificationService    -> smsComponent        "SMS"
        emailComponent      -> msgService            "REST/HTTPS"
        pushComponent       -> msgService            "REST/HTTPS"
        smsComponent        -> msgService            "REST/HTTPS"

        reportController    -> reportService         "Genera informe"
        reportService       -> exportComponent       "Exporta CSV/PDF"
        reportService       -> database              "Extrae datos históricos"

        // Relaciones externas de contenedores
        agricultor    -> landingPage    "Visita y registra cuenta"
        agricultor    -> webApp         "Gestiona cultivos, diagnósticos y reportes"
        agricultor    -> mobileApp      "Captura fotos, diagnóstico offline y sincronización"

        webApp        -> apiGateway     "REST calls"
        mobileApp     -> apiGateway     "REST calls / Sync"
        apiGateway    -> loadBalancer   "Routea según path"
        loadBalancer  -> apiSecurity
        loadBalancer  -> apiUsers
        loadBalancer  -> apiCrops
        loadBalancer  -> apiDiagnosis
        loadBalancer  -> apiTreatments
        loadBalancer  -> apiSync
        loadBalancer  -> apiNotifications
        loadBalancer  -> apiReports
        loadBalancer -> apiSubscriptions

        // Integración con servicios externos
        apiReports       -> weatherApi "Enriquece con datos climáticos" "REST/HTTPS"
        apiNotifications -> msgService "Envía solicitudes de notificación" "REST/HTTPS"

        // Despliegue
        deploymentEnvironment "Producción" {
    deploymentNode "GitHub" "Hosting estático" {
        deploymentNode "GitHub Pages" "Landing Page" {
            containerInstance landingPage
        }
    }

    deploymentNode "Vercel" "Frontend Hosting" {
        deploymentNode "WebApp Hosting" "Hospeda Angular WebApp" {
            containerInstance webApp
        }
    }

    deploymentNode "Tiendas Móviles" "Distribución de la App Móvil" {
        deploymentNode "Google Play Store" "Distribución para Android" {
            containerInstance mobileApp
        }
        deploymentNode "Apple App Store" "Distribución para iOS" {
            containerInstance mobileApp
        }
    }

    deploymentNode "AWS" "Proveedor Cloud" {
        deploymentNode "API Gateway" "Gateway administrado" {
            containerInstance apiGateway
        }
        deploymentNode "Application Load Balancer" "Balanceador capa 7" {
            containerInstance loadBalancer
        }
        deploymentNode "EC2 Auto Scaling" "Instancias backend escalables" "Ubuntu 22.04" {
            containerInstance apiSecurity
            containerInstance apiUsers
            containerInstance apiCrops
            containerInstance apiDiagnosis
            containerInstance apiTreatments
            containerInstance apiSync
            containerInstance apiNotifications
            containerInstance apiReports
        }
        deploymentNode "RDS PostgreSQL" "Base de datos relacional" {
            containerInstance database
        }
        deploymentNode "S3 Bucket" "Almacenamiento de imágenes" {
            containerInstance storageService
        }
        deploymentNode "SageMaker Endpoint" "Endpoint modelo IA" {
            containerInstance aiService
        }
    }

    deploymentNode "Infraestructura Física" "Campo" {
        infrastructureNode "Mobile Local Storage"
    }

    deploymentNode "Servicios Externos" "Proveedores API" {
        infrastructureNode "API Meteorológica"
        infrastructureNode "Servicio de Mensajería"
    }
}

    }

    views {
        systemLandscape landscape_hidrogreen_ecosistema {
            include *
            autoLayout lr
            description """
                Landscape completo de HidroGreen: usuarios, sistemas externos, frontends, microservicios y despliegue.
            """
        }

        systemContext hidroGreen context {
            include *
            autoLayout lr
        }

        container hidroGreen containerView {
            include *
            autoLayout lr
        }

        component apiDiagnosis componentsDiagnosis {
            include *
            autoLayout
        }

        component apiTreatments componentsTreatments {
            include *
            autoLayout
        }

        component apiSync componentsSync {
            include *
            autoLayout
        }
    
        component apiSecurity componentsSecurity {
            include *
            autoLayout
        }

        component apiUsers componentsUsers {
            include *
            autoLayout
        }

        component apiCrops componentsCrops {
            include *
            autoLayout
        }
        component apiNotifications componentsNotifications {
            include *
            autoLayout
        }
        
        component apiSubscriptions componentsSubscriptions {
            include *
            autoLayout
        }

        component apiReports componentsReports {
            include *
            autoLayout
        }
   

        deployment hidroGreen "Producción" {
            include *
            autoLayout lr
            description "Despliegue en GitHub, Vercel y AWS, con S3 y SageMaker para IA."
        }

        styles {
             element "Person" {
                shape person
                background #08427b
                color #ffffff
            }
            element "Web Browser" {
                shape webbrowser
            }
            element "Web Application" {
                shape webbrowser
                background #457799
            }
            element "Mobile App" {
                shape mobiledevicelandscape
            }
            element "Software System" {
                shape roundedbox
                background #1168bd
                color #ffffff
            }
            element "Extern System" {
                shape roundedbox
                background #929994
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "API Gateway" {
                shape hexagon
                background #22cc88
                color #ffffff
            }
            element "Load Balancer" {
                shape hexagon
                background #ffaa22
                color #ffffff
            }
            element "API" {
                shape hexagon
                background #ffb600
                color #ffffff
            }
            element "Database" {
                shape cylinder
                background #ff3333
                color #ffffff
            }
            element "Component" {
                shape component
                background #85bbf0
                color #ffffff
            }
            element "Infrastructure Node" {
                shape roundedbox
                background #dddddd
                color #000000
            }
            element "Deployment Node" {
                shape folder
                background #eeeeee
                color #000000
            }
        }
    }

    configuration {
        scope softwareSystem
    }
}
