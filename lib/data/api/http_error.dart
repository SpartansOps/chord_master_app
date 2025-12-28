class ResponseApi {
  static String getMessage(int? statusCode) {
    switch (statusCode) {
      case ResponseCode.badRequest:
        return ResponseMessage.badRequest;
      case ResponseCode.forbidden:
        return ResponseMessage.forbidden;
      case ResponseCode.notFound:
        return ResponseMessage.notFound;
      case ResponseCode.internalServerError:
        return ResponseMessage.internalServerError;
      default:
        return ResponseMessage.unknown;
    }
  }
}

class ResponseCode {
  static const int badRequest = 400;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int internalServerError = 500;
}

class ResponseMessage {
  static const String badRequest = "O servidor não conseguiu entender a solicitação. Certifique-se de fornecer dados válidos e formatados corretamente.";
  static const String forbidden = "Acesso proibido por motivos de segurança. Caso acredite que isso seja um erro, entre em contato com a equipe de suporte.";
  static const String notFound = "Desculpe, o recurso solicitado não pôde ser encontrado no servidor.";
  static const String internalServerError = "Desculpe, ocorreu um erro interno no servidor. Por favor, tente novamente mais tarde.";
  static const String unknown = "Ops! Tivemos um problema desconhecido, tente novamente mais tarde!";
}