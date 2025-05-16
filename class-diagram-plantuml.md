@startuml
' PlantUML version with improved layout using grouping
' direction TB

left to right direction
allowmixing

title System Class Diagram

' ==============================================================
' AGREGANDO GRUPOS PARA MEJORAR EL LAYOUT Y CLARIDAD
' ==============================================================

' --------------------------------------------------------------
rectangle "Domain Model" {
  ' Define Classes (Entities/Value Objects)
  class User {
    + UUID id
    + String username
    + String hashedPassword
    + String email
    + UserProfile profile
    + List<UserPreference> preferences
    + List<Crop> crops
    + List<Subscription> subscriptions
    + DateTime createdAt
    + DateTime updatedAt
    + validatePassword(plainPassword)
    + updateProfile(profileData)
  }

  class UserProfile {
    + String firstName
    + String lastName
    + String phoneNumber
    + Address address
  }

  class UserPreference {
    + String key
    + String value
  }

  class Crop {
    + UUID id
    + String name
    + String variety
    + PlantingDate plantingDate
    + HarvestDate expectedHarvestDate
    + List<CropStage> stages
    + List<Diagnosis> diagnoses
    + List<HistoryLog> history
    + User owner
    + addLogEntry(entry)
  }

  class CropStage {
    + String name
    + DateTime startDate
    + DateTime endDate
  }

  class HistoryLog {
    + UUID id
    + DateTime timestamp
    + String eventType
    + String description
    + User performedBy
  }

  class Diagnosis {
    + UUID id
    + ImageMetadata image
    + String diseaseDetected
    + Float confidenceScore
    + DateTime diagnosisDate
    + TreatmentPlan recommendedTreatment
    + Crop crop
  }

  class ImageMetadata {
    + String originalFileName
    + String storagePath
    + String mimeType
    + Long size
  }

  class TreatmentPlan {
    + UUID id
    + String description
    + List<RecommendedAction> actions
    + List<ShoppingListItem> shoppingList
    + Diagnosis diagnosis
  }

  class RecommendedAction {
    + String actionDescription
    + String productToUse
    + String dosage
  }

  class ShoppingListItem {
    + String productName
    + String quantity
    + String notes
  }

  class Subscription {
    + UUID id
    + User user
    + Plan plan
    + DateTime startDate
    + DateTime endDate
    + SubscriptionStatus status
    + List<PaymentRecord> paymentHistory
  }

  class Plan {
    + UUID id
    + String name
    + Money price
    + String billingCycle (e.g., MONTHLY, YEARLY)
    + List<String> features
  }

  class PaymentRecord {
    + UUID id
    + DateTime paymentDate
    + Money amount
    + String transactionId
    + PaymentStatus status
  }

  class NotificationLog {
    + UUID id
    + User recipient
    + NotificationChannel channel (EMAIL, SMS, PUSH)
    + String subject
    + String content
    + DateTime sentAt
    + NotificationStatus status
  }

  ' Define Enums
  enum SubscriptionStatus {
    ACTIVE
    INACTIVE
    CANCELLED
    PAST_DUE
  }

  enum PaymentStatus {
    SUCCESSFUL
    PENDING
    FAILED
  }

  enum NotificationChannel {
    EMAIL
    SMS
    PUSH
  }

  enum NotificationStatus {
    SENT
    FAILED
    PENDING
  }
}
' --------------------------------------------------------------

' --------------------------------------------------------------
rectangle "Data Transfer Objects" {
  ' Define DTOs (Classes with <<DTO>> stereotype)
  class UserDTO <<DTO>> {
    + UUID id
    + String username
    + String email
    + UserProfileDTO profile
  }

  class CropDTO <<DTO>> {
    + UUID id
    + String name
  }

  class DiagnosisRequestDTO <<DTO>> {
    + File imageFile
    + UUID cropId
  }

  class DiagnosisResultDTO <<DTO>> {
    + UUID diagnosisId
    + String disease
    + Float confidence
  }

  class SubscriptionDTO <<DTO>> {
    + UUID id
    + String planName
    + String status
  }
}
' --------------------------------------------------------------

' --------------------------------------------------------------
rectangle "Application & Infrastructure Interfaces" {
  ' Define Interfaces
  interface IUserRepository {
    + save(User user): User
    + findById(UUID id): User
    + findByUsername(String username): User
    + findAll(): List<User>
  }

  interface ICropRepository {
    + save(Crop crop): Crop
    + findById(UUID id): Crop
    + findByUser(User user): List<Crop>
  }

  interface IDiagnosisRepository {
    + save(Diagnosis diagnosis): Diagnosis
    + findById(UUID id): Diagnosis
    + findByCrop(Crop crop): List<Diagnosis>
  }

  interface ITreatmentPlanRepository {
    + save(TreatmentPlan plan): TreatmentPlan
    + findById(UUID id): TreatmentPlan
  }

  interface ISubscriptionRepository {
    + save(Subscription subscription): Subscription
    + findById(UUID id): Subscription
    + findByUser(User user): List<Subscription>
  }

  interface IHistoryLogRepository {
    + save(HistoryLog log): HistoryLog
  }

  interface IPaymentRecordRepository {
    + save(PaymentRecord record): PaymentRecord
  }

  interface INotificationLogRepository {
    + save(NotificationLog log): NotificationLog
  }

  interface ISecurityService <<service>> {
    + login(username, password): TokenDTO
    + register(RegisterUserDTO dto): UserDTO
    + validateToken(token): UserPrincipal
  }

  interface IUserService <<service>> {
    + createUser(UserCreationDTO dto): UserDTO
    + getUserById(UUID id): UserDTO
    + updateUserProfile(UUID userId, ProfileDTO dto): UserDTO
    + getUserPreferences(UUID userId): List<PreferenceDTO>
  }

  interface ICropService <<service>> {
    + createCrop(UUID userId, CropCreationDTO dto): CropDTO
    + getCropById(UUID cropId): CropDTO
    + addHistoryToCrop(UUID cropId, HistoryLogDTO dto)
  }

  interface IDiagnosisOrchestrationService <<service>> {
    + requestDiagnosis(DiagnosisRequestDTO dto): UUID_jobId
    + getDiagnosisResult(UUID diagnosisId): DiagnosisResultDTO
  }

  interface ISubscriptionService <<service>> {
    + createSubscription(UUID userId, PlanIdDTO dto): SubscriptionDTO
    + cancelSubscription(UUID subscriptionId)
    + processPaymentWebhook(WebhookPayload payload)
  }

  interface ITreatmentService <<service>> {
    + generateTreatmentPlan(UUID diagnosisId): TreatmentPlanDTO
    + getShoppingList(UUID treatmentPlanId): List<ShoppingListItemDTO>
  }

  interface ISyncService <<service>> {
    + synchronizeClientData(ClientDataBatchDTO dto): SyncResultDTO
  }

  interface INotificationOrchestrationService <<service>> {
    + sendDiagnosisReadyNotification(UserDTO user, DiagnosisResultDTO diagnosis)
    + sendSubscriptionReminder(UserDTO user, SubscriptionDTO subscription)
  }

  interface IReportService <<service>> {
    + generateCropPerformanceReport(UUID userId, DateRangeDTO range): ReportDataDTO
    + exportReport(ReportDataDTO data, ExportFormat format): File
  }

  interface IJwtService <<service>> {
    + generateToken(UserPrincipal principal): String
    + validateTokenAndGetPrincipal(String token): UserPrincipal
  }

  interface IPaymentGateway <<gateway>> {
    + initiatePayment(PaymentRequestDTO dto): PaymentResponseDTO
    + verifyPayment(String transactionId): PaymentStatus
  }

  interface IQueueService <<service>> {
    + publish(String queueName, MessageDTO message)
    + subscribe(String queueName, MessageHandler handler)
  }

  interface IAIService <<service>> {
    + performInference(ImageFile image): AIServiceResultDTO
  }

  interface IStorageService <<service>> {
    + uploadFile(String bucket, String key, File file): FileURL
    + downloadFile(String bucket, String key): File
  }

  interface IWeatherService <<service>> {
    + getForecast(LocationDTO location): WeatherForecastDTO
  }

  interface IExternalMessageSender <<service>> {
    + sendEmail(EmailDTO dto)
    + sendSms(SmsDTO dto)
    + sendPushNotification(PushDTO dto)
  }

  interface IDataExporter <<service>> {
    + exportToCsv(Object data, String fileName): File
    + exportToPdf(Object data, String fileName): File
  }
}
' --------------------------------------------------------------

' --------------------------------------------------------------
rectangle "Infrastructure Implementations" {
  ' Define Implementations (Classes)
  class PostgresUserRepository {
    + DataSource dataSource
  }

  class PostgresCropRepository {
    + DataSource dataSource
  }

  class PostgresDiagnosisRepository {
    + DataSource dataSource
  }

  class PostgresTreatmentPlanRepository {
    + DataSource dataSource
  }

  class PostgresSubscriptionRepository {
    + DataSource dataSource
  }

  class PostgresHistoryLogRepository {
    + DataSource dataSource
  }

  class PostgresPaymentRecordRepository {
    + DataSource dataSource
  }

  class PostgresNotificationLogRepository {
    + DataSource dataSource
  }

  class SpringJwtService {
    + String jwtSecret
    + Long jwtExpirationMs
  }

  class NiubizPaymentGatewayAdapter {
    + String apiKey
    + String secretKey
    + HttpClient httpClient
  }

  class RabbitMQService {
    + ConnectionFactory connectionFactory
  }

  class AwsS3StorageService {
    + S3Client s3Client
  }

  class AwsSageMakerAIService {
    + SageMakerClient sageMakerClient
  }

  class ExternalWeatherApiClient {
    + String apiUrl
    + String apiKey
    + HttpClient httpClient
  }

  class MsgServiceAdapter {
    + String apiUrl
    + String apiKey
    + HttpClient httpClient
  }

  class DataExporterImpl {
    ' Libraries for PDF/CSV generation
  }
}
' --------------------------------------------------------------

' --------------------------------------------------------------
rectangle "Presentation Layer" {
  ' Define Controllers (Classes)
  class SecurityController {
    + ISecurityService securityService
    + login(LoginRequest req): ResponseEntity
    + register(RegisterRequest req): ResponseEntity
  }

  class UserController {
    + IUserService userService
    + createUser(UserCreationRequest req): ResponseEntity
    + getUser(UUID id): ResponseEntity
  }

  class CropController {
    + ICropService cropService
    + createCrop(CropCreationRequest req): ResponseEntity
    + getCrop(UUID id): ResponseEntity
  }

  class DiagnosisController {
    + IDiagnosisOrchestrationService diagnosisService
    + uploadImageForDiagnosis(MultipartFile image, UUID cropId): ResponseEntity
  }

  class SubscriptionController {
    + ISubscriptionService subscriptionService
    + subscribe(SubscriptionRequest req): ResponseEntity
    + niubizWebhook(WebhookPayload payload): ResponseEntity
  }

  class TreatmentController {
    + ITreatmentService treatmentService
    + getTreatmentForDiagnosis(UUID diagnosisId): ResponseEntity
  }

  class SyncController {
    + ISyncService syncService
    + syncData(SyncDataRequest req): ResponseEntity
  }

  class NotificationController {
    + INotificationOrchestrationService notificationService
    ' Endpoints typically triggered by internal events, or admin actions
  }

  class ReportController {
    + IReportService reportService
    + getCropReport(ReportRequest req): ResponseEntity
  }
}
' --------------------------------------------------------------

' --------------------------------------------------------------
rectangle "Background Workers" {
  ' Define Workers (Classes)
  class AiInferenceWorker {
    + IQueueService queueService
    + IAIService aiService
    + IDiagnosisRepository diagnosisRepository
    + processDiagnosisJob(DiagnosisJobMessage message)
  }
}
' --------------------------------------------------------------

' --------------------------------------------------------------
rectangle "External Systems" {
  ' Define External Systems
  class WeatherAPI <<external>> {
  }

  class MessagingService <<external>> {
  }
  class NiubizGateway <<external>> {
  }
  class S3Bucket <<external>> {
  }
  class SageMaker <<external>> {
  }
}
' --------------------------------------------------------------

' Define Actor
actor Agricultor


' ==============================================================
' RELACIONES (DEFINIDAS DESPUÉS DE TODOS LOS ELEMENTOS AGRUPADOS)
' ==============================================================

' Dependencies (Service -> Repository/Other Services)
ISecurityService ..> IUserRepository
ISecurityService ..> IJwtService
IUserService ..> IUserRepository
ICropService ..> ICropRepository
ICropService ..> IHistoryLogRepository
IDiagnosisOrchestrationService ..> IQueueService
IDiagnosisOrchestrationService ..> IStorageService
IDiagnosisOrchestrationService ..> IDiagnosisRepository
ISubscriptionService ..> ISubscriptionRepository
ISubscriptionService ..> IPaymentRecordRepository
ISubscriptionService ..> IPaymentGateway
ISubscriptionService ..> IUserRepository
ITreatmentService ..> ITreatmentPlanRepository
ITreatmentService ..> IDiagnosisRepository
ISyncService ..> IUserRepository
ISyncService ..> ICropRepository
ISyncService ..> IDiagnosisRepository
INotificationOrchestrationService ..> IExternalMessageSender
INotificationOrchestrationService ..> INotificationLogRepository
IReportService ..> ICropRepository
IReportService ..> IDiagnosisRepository
IReportService ..> IWeatherService
IReportService ..> IDataExporter

' Associations (Entity Relationships within Domain)
User "1" -- "0..*" Crop : manages
User "1" -- "0..*" Subscription : has
Crop "1" -- "0..*" Diagnosis : undergoes
Crop "1" -- "0..*" HistoryLog : logs
Diagnosis "1" -- "0..1" TreatmentPlan : recommends
Subscription "1" -- "0..*" PaymentRecord : records
User "1" -- "1" UserProfile : has_profile
User "1" -- "0..*" UserPreference : has_preferences
Subscription "1" -- "1" Plan : uses

' Aggregations (Controller/Worker uses Service/Repository)
SecurityController o-- ISecurityService
UserController o-- IUserService
CropController o-- ICropService
DiagnosisController o-- IDiagnosisOrchestrationService
SubscriptionController o-- ISubscriptionService
TreatmentController o-- ITreatmentService
SyncController o-- ISyncService
NotificationController o-- INotificationOrchestrationService
ReportController o-- IReportService
AiInferenceWorker o-- IQueueService
AiInferenceWorker o-- IAIService
AiInferenceWorker o-- IDiagnosisRepository

' Implementations (Concrete classes implement Interfaces)
PostgresUserRepository ..|> IUserRepository
PostgresCropRepository ..|> ICropRepository
PostgresDiagnosisRepository ..|> IDiagnosisRepository
PostgresTreatmentPlanRepository ..|> ITreatmentPlanRepository
PostgresSubscriptionRepository ..|> ISubscriptionRepository
PostgresHistoryLogRepository ..|> IHistoryLogRepository
PostgresPaymentRecordRepository ..|> IPaymentRecordRepository
PostgresNotificationLogRepository ..|> INotificationLogRepository

SpringJwtService ..|> IJwtService
NiubizPaymentGatewayAdapter ..|> IPaymentGateway
RabbitMQService ..|> IQueueService
AwsS3StorageService ..|> IStorageService
AwsSageMakerAIService ..|> IAIService
ExternalWeatherApiClient ..|> IWeatherService
MsgServiceAdapter ..|> IExternalMessageSender
DataExporterImpl ..|> IDataExporter

' Actor Interactions
Agricultor --> SecurityController : interacts
Agricultor --> UserController : interacts
Agricultor --> CropController : interacts
Agricultor --> DiagnosisController : interacts
Agricultor --> SubscriptionController : interacts
Agricultor --> TreatmentController : interacts
Agricultor --> SyncController : interacts
Agricultor --> ReportController : interacts

' Adapter/Worker Interactions with External Systems or other infrastructure
NiubizPaymentGatewayAdapter ..> NiubizGateway : uses
ExternalWeatherApiClient ..> WeatherAPI : uses
MsgServiceAdapter ..> MessagingService : uses
AwsS3StorageService ..> S3Bucket : uses
AwsSageMakerAIService ..> SageMaker : uses
AiInferenceWorker ..> SageMaker : triggers_inference
AiInferenceWorker ..> RabbitMQService : consumes_from
IDiagnosisOrchestrationService ..> RabbitMQService : publishes_to
IDiagnosisOrchestrationService ..> S3Bucket : stores_image_in

@enduml
