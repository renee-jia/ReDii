export interface RediiRequest extends Request {
  env: any;
}

export interface MessagePolishRequest {
  text: string;
}

export interface MessagePolishResponse {
  polishedText: string;
}

export interface DailyPromptResponse {
  prompt: string;
}

export interface Moment {
  id: string;
  type: string;
  content: string;
  createdAt: string;
  authorID: string;
  photoURL?: string;
  voiceURL?: string;
  mood?: {
    emoji: string;
    label: string;
  };
}

export interface WeeklySummaryRequest {
  moments: Moment[];
}

export interface WeeklySummaryResponse {
  summary: string;
}

export interface ApiError {
  error: string;
}

