export interface CloudAiProxyRequest {
  prompt: string;
  maxTokens?: number;
  // Base64 bytes only (no data: prefix)
  imageBase64Jpeg: string;
  // Optional correlation id for logging-safe tracing
  requestId?: string;
}

export type CloudAiProxyResponse =
  | {
    text: string;
    raw: unknown;
    requestId?: string;
  }
  | {
    error: string;
    requestId?: string;
  };
