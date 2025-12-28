import { useLexicalComposerContext } from "@lexical/react/LexicalComposerContext";
import { $generateHtmlFromNodes, $generateNodesFromDOM } from "@lexical/html";
import { $getRoot } from "lexical";
import { useEffect } from "react";

export function FlutterBridgePlugin() {
    const [editor] = useLexicalComposerContext();

    useEffect(() => {
        (window as any).sendDataToFlutter = () => {
            editor.update(() => {
                const html = $generateHtmlFromNodes(editor);

                // 1. Kiểm tra nếu là Windows (Edge WebView2)
                if ((window as any).chrome && (window as any).chrome.webview) {
                    (window as any).chrome.webview.postMessage(html);
                }
                // 2. Kiểm tra nếu là macOS/Mobile (InAppWebView)
                else if ((window as any).flutter_inappwebview) {
                    (window as any).flutter_inappwebview.callHandler('onSave', html);
                } else {
                    console.log("HTML:", html);
                }
            });
        };

        (window as any).setContent = (html: string) => {
            editor.update(() => {
                const parser = new DOMParser();
                const dom = parser.parseFromString(html, "text/html");
                const nodes = $generateNodesFromDOM(editor, dom);
                $getRoot().clear();
                $getRoot().append(...nodes);
            });
        };

        return () => {
            delete (window as any).sendDataToFlutter;
            delete (window as any).setContent;
        };
    }, [editor]);

    return null;
}
