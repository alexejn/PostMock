//
// Created by Alexey Nenastyev on 5.6.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI
import WebKit

struct JSONView: UIViewRepresentable {
  var json: String

  func makeUIView(context: Context) -> WKWebView {
    let webView =  WKWebView()
    return webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {
    uiView.loadHTMLString(htmlForJson(json), baseURL: nil)
  }

  static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
      uiView.stopLoading()
      uiView.navigationDelegate = nil
      uiView.removeFromSuperview()
  }
  
  private func htmlForJson(_ jsonString: String) -> String {
    let escapedJsonString = jsonString
      .replacingOccurrences(of: "\\", with: "\\\\")
      .replacingOccurrences(of: "\"", with: "\\\"")
      .replacingOccurrences(of: "\n", with: "\\n")
      .replacingOccurrences(of: "\r", with: "\\r")
      .replacingOccurrences(of: "\t", with: "\\t")

    let htmlTemplate = """
          <!DOCTYPE html>
          <html>
          <head>
              <title>JSON Viewer</title>
              <style>
                  body {
                      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                      margin: 0;
                      padding: 0;
                      background-color: #ffffff;
                  }
                  pre {
                      background-color: #ffffff;
                      color: #000000;
                      padding: 1em;
                      white-space: pre-wrap;
                      word-wrap: break-word;
                      border: none;
                  }
                  .key {
                      color: #d73a49;
                  }
                  .string {
                      color: #032f62;
                  }
                  .number {
                      color: #005cc5;
                  }
                  .boolean {
                      color: #e36209;
                  }
                  .null {
                      color: #6f42c1;
                  }
              </style>
          </head>
          <body>
              <pre id="json"></pre>
              <script>
                  function syntaxHighlight(json) {
                      json = json.replace(/(&)/g, '&amp;').replace(/(\\\\<)/g, '&lt;').replace(/(\\\\>)/g, '&gt;');
                      return json.replace(/("(\\\\u[a-zA-Z0-9]{4}|[^\\\\u"])*"(\\s*:\\s*|\\s*:)?|\\b(true|false|null)\\b|-?\\d+(?:\\\\.\\d*)?(?:[eE][+-]?\\d+)?)/g, function (match) {
                          var cls = 'number';
                          if (/^"/.test(match)) {
                              if (/:$/.test(match)) {
                                  cls = 'key';
                              } else {
                                  cls = 'string';
                              }
                          } else if (/true|false/.test(match)) {
                              cls = 'boolean';
                          } else if (/null/.test(match)) {
                              cls = 'null';
                          }
                          return '<span class="' + cls + '">' + match + '</span>';
                      });
                  }
                  document.getElementById('json').innerHTML = syntaxHighlight("\(escapedJsonString)");
              </script>
          </body>
          </html>
          """
    return htmlTemplate
  }
}
