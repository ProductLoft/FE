// names of columns for user table
const String userTable = "user";
const String userIdColumn = "id";
const String nameColumn = "name";
const String usernameColumn = "username";
const String emailColumn = "email";
const String cookieColumn = "cookie";
const String csrfTokenColumn = "csrfToken";

// names of columns for recording table
const String recordingTable = "recording";
const String recordingIdColumn = "id";
const String filePathColumn = "filePath";
const String commentColumn = "comment";
const String timestampColumn = "timestamp";
const String isProcessedColumn = "isProcessed";
const String insightsDirPathColumn = "zipPath";
const String audioIdColumn = "audioId";

// consts for network calls
const String baseUrl = "http://52.72.143.117:8000";
const String loginUri = "/auth/login/";
const String uploadUri = "/audio-record/upload/";
const String jobStatusUri = "/check_job_status/";
const String downloadZipUri = "/speaker-turn/download/";


// FilePaths
const String audioPath = "audio";
const String zipPath = "zip";
const String insightPath = "insights";
const dbPath = "db/lang.db";