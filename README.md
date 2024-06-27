# PostMock

PostMock is a powerful mocking framework that uses Postman.

It brings Postman into your application and provides the following capabilities:
- Mock any request with responses from Postman.
- View network calls linked to postman requests.

Find our public api collection in Postman called [PostMock](https://www.postman.com/universal-moon-430028/workspace/postmock).
Which we used in demo app inside.

<img height="300" alt="image" src="https://github.com/alexejn/PostMock/assets/19667729/adf22cc4-5f35-4684-9bb7-6271c8b23091">
<img height="300" alt="image" src="https://github.com/alexejn/PostMock/assets/19667729/e7510abf-ac28-438d-a506-c3bc8239a37c">
<img height="300" alt="image" src="https://github.com/alexejn/PostMock/assets/19667729/b01a89f3-9de8-4f77-80b1-069571d717b3">
<img height="300" alt="image" src="https://github.com/alexejn/PostMock/assets/19667729/074e6043-8dda-43b7-ae97-ef5c1bee6a1b">
<img height="300" alt="image" src="https://github.com/alexejn/PostMock/assets/19667729/fb37210b-b6ec-41b4-a95f-1df860baf15c">

<img height="300" alt="image" src="https://github.com/alexejn/PostMock/assets/19667729/9831a53c-3419-491f-a45d-fc00515d4430">
<img height="300" alt="image" src="https://github.com/alexejn/PostMock/assets/19667729/19a74213-88cf-4bae-9864-feb61833ef8c">



## Configurate

```swift
import PostMockSDK

struct ContentView: View {
  var body: some View {
    DogsList()
      // Add PostMock button or use PostMockView direclty and add it to any view you wan't, or call it on shake.
      .overlayPostMockButton()
      .onAppear {
        // Provide your POSTMAN_API_KEY and WORKSPACE_ID wich api collections you want to use 
        let config = PostMock.Config(apiKey: "<POSTMAN_API_KEY>",
                                     workspaceID: "<WORKSPACE_ID>")

        PostMock.shared.configurate(with: config)
        /// Add some environment variables (optional), see description below
        PostMock.shared.environment.set(key: "host",
                                        scope: .request,
                                        provider: { "https://dogapi.dog" })
      }
  }
}

```
You also need [MockServer](https://learning.postman.com/docs/designing-and-developing-your-api/mocking-data/setting-up-mock/) in Postman for api collection.

 
## Matching
To match requests from the app to Postman requests, we can use templates or set a specific header `x-postmock-request-id` to the request.

<img width="300" alt="image" src="https://github.com/alexejn/PostMock/assets/19667729/43948f10-51dc-4557-be19-0e5db9d378d3">


You can provide some variables to make the mock more specific.

<img width="300" alt="image" src="https://github.com/alexejn/PostMock/assets/19667729/71ca1321-743b-47c8-9c1e-aba542cef173">


Some of these variables are global and are applied to any request containing the placeholder.

<img width="300" alt="image" src="https://github.com/alexejn/PostMock/assets/19667729/0f681a1a-2a7e-4203-b695-759eb71c9f8f)">

We set them up in the code:

```swift
 PostMock.shared.environment.set(key: "host",
                                 scope: .request,
                                 provider: { "https://dogapi.dog" })
```
If you do not specify global variables like `{{host}}`, they will be matched to any string.

It’s not a problem when you have only one host for requests.

## In code mocking 
You can mock some request in preview or tests. There is opportunity to set mock from code: 
```swift
    /// response id from postman
    let mastiff200 = "1122734-8c545657-d643-4db4-b216-d16d699b27fa"

    /// Default MockServer from workspace https://www.postman.com/universal-moon-430028/workspace/postmock
    PostMock.shared.mockServer = MockServer(host: "0997c312-c8ea-435a-8ffd-4a98f4214024.mock.pstmn.io")


    Mock
      .request("GET", url: "{{host}}/api/v2/facts")
      .with(responseID: .mastiff200)
      .set()

    PostMock.shared.mockIsEnabled = true

```
