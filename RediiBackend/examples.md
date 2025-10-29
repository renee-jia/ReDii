# Redii Backend API Examples

## Message Polish

### Request
```bash
curl -X POST https://your-worker.workers.dev/ai/message-polish \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "We had a nice walk in the park today"
  }'
```

### Response
```json
{
  "polishedText": "We shared a lovely, peaceful stroll through the park together today, surrounded by gentle nature's beauty"
}
```

## Daily Prompt

### Request
```bash
curl -X GET https://your-worker.workers.dev/ai/daily-prompt \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

### Response
```json
{
  "prompt": "What was the sweetest moment you shared today?"
}
```

## Weekly Summary

### Request
```bash
curl -X POST https://your-worker.workers.dev/ai/weekly-summary \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "moments": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "type": "note",
        "content": "Morning coffee together",
        "createdAt": "2024-01-15T08:00:00Z",
        "authorID": "user-1"
      },
      {
        "id": "550e8400-e29b-41d4-a716-446655440001",
        "type": "photo",
        "content": "Sunset walk",
        "createdAt": "2024-01-15T19:00:00Z",
        "authorID": "user-2"
      },
      {
        "id": "550e8400-e29b-41d4-a716-446655440002",
        "type": "mood",
        "content": "Feeling grateful",
        "createdAt": "2024-01-16T10:00:00Z",
        "authorID": "user-1",
        "mood": {
          "emoji": "😊",
          "label": "Happy"
        }
      }
    ]
  }'
```

### Response
```json
{
  "summary": "This week has been a beautiful tapestry of shared moments. From quiet mornings sipping coffee together to gentle evening walks watching the sun set, each day brought new reasons to smile. The simple act of being present with one another, sharing gratitude and joy, created a sanctuary of connection. These precious memories are the threads that weave your love story."
}
```

## Error Examples

### Missing Authorization
```bash
curl -X POST https://your-worker.workers.dev/ai/message-polish \
  -H "Content-Type: application/json" \
  -d '{"text":"Hello"}'
```

Response (401):
```json
{
  "error": "Missing Authorization header"
}
```

### Rate Limit Exceeded
```bash
# After 100 requests in 15 minutes
curl -X GET https://your-worker.workers.dev/ai/daily-prompt \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

Response (429):
```json
{
  "error": "Rate limit exceeded"
}
```

## Swift Integration Example

```swift
struct AIAPIClient {
    let baseURL: String
    let apiToken: String
    
    func polishMessage(_ text: String) async throws -> String {
        let url = URL(string: "\(baseURL)/ai/message-polish")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["text": text]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode([String: String].self, from: data)
        
        return response["polishedText"] ?? text
    }
}
```

