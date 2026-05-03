import Foundation
import WebKit

enum FingerprintProtection {
    static let fingerprintScript: String = """
    (function() {
      'use strict';
      try {
        const def = (obj, prop, value) => {
          try {
            Object.defineProperty(obj, prop, { get: () => value, configurable: true });
          } catch(e) {}
        };

        def(navigator, 'hardwareConcurrency', 4);
        def(navigator, 'deviceMemory', 4);
        def(navigator, 'maxTouchPoints', 5);
        def(navigator, 'platform', 'iPhone');
        def(navigator, 'vendor', 'Apple Computer, Inc.');
        def(navigator, 'plugins', []);
        def(navigator, 'mimeTypes', []);
        def(navigator, 'doNotTrack', '1');
        def(navigator, 'languages', ['en-US', 'en']);
        def(navigator, 'webdriver', false);

        try {
          def(screen, 'colorDepth', 24);
          def(screen, 'pixelDepth', 24);
        } catch(e) {}

        try {
          Date.prototype.getTimezoneOffset = function() { return 0; };
          if (typeof Intl !== 'undefined' && Intl.DateTimeFormat) {
            const orig = Intl.DateTimeFormat.prototype.resolvedOptions;
            Intl.DateTimeFormat.prototype.resolvedOptions = function() {
              const r = orig.call(this);
              r.timeZone = 'UTC';
              return r;
            };
          }
        } catch(e) {}

        try {
          const noisy = (data) => {
            for (let i = 0; i < data.length; i += 4) {
              data[i]   = data[i]   ^ (Math.random() < 0.5 ? 1 : 0);
              data[i+1] = data[i+1] ^ (Math.random() < 0.5 ? 1 : 0);
              data[i+2] = data[i+2] ^ (Math.random() < 0.5 ? 1 : 0);
            }
            return data;
          };
          const origToDataURL = HTMLCanvasElement.prototype.toDataURL;
          HTMLCanvasElement.prototype.toDataURL = function() {
            try {
              const ctx = this.getContext('2d');
              if (ctx) {
                const w = this.width, h = this.height;
                if (w > 0 && h > 0) {
                  const img = ctx.getImageData(0, 0, w, h);
                  noisy(img.data);
                  ctx.putImageData(img, 0, 0);
                }
              }
            } catch(e) {}
            return origToDataURL.apply(this, arguments);
          };
          const origGetImageData = CanvasRenderingContext2D.prototype.getImageData;
          CanvasRenderingContext2D.prototype.getImageData = function() {
            const data = origGetImageData.apply(this, arguments);
            try { noisy(data.data); } catch(e) {}
            return data;
          };
        } catch(e) {}

        try {
          const wrapGetParam = (proto) => {
            const orig = proto.getParameter;
            proto.getParameter = function(p) {
              if (p === 37445) return 'Apple Inc.';
              if (p === 37446) return 'Apple GPU';
              if (p === 7936)  return 'WebKit';
              if (p === 7937)  return 'WebKit WebGL';
              return orig.call(this, p);
            };
          };
          if (typeof WebGLRenderingContext !== 'undefined') wrapGetParam(WebGLRenderingContext.prototype);
          if (typeof WebGL2RenderingContext !== 'undefined') wrapGetParam(WebGL2RenderingContext.prototype);
        } catch(e) {}

        try {
          if (typeof AudioBuffer !== 'undefined') {
            const origGetChannelData = AudioBuffer.prototype.getChannelData;
            AudioBuffer.prototype.getChannelData = function() {
              const r = origGetChannelData.apply(this, arguments);
              for (let i = 0; i < r.length; i += 100) {
                r[i] = r[i] + (Math.random() * 1e-7);
              }
              return r;
            };
          }
        } catch(e) {}

        try {
          if (navigator.getBattery) {
            navigator.getBattery = () => Promise.resolve({
              charging: true, chargingTime: 0, dischargingTime: Infinity, level: 1,
              addEventListener: () => {}, removeEventListener: () => {}
            });
          }
        } catch(e) {}

        try {
          if (navigator.connection) {
            def(navigator.connection, 'effectiveType', '4g');
            def(navigator.connection, 'rtt', 50);
            def(navigator.connection, 'downlink', 10);
          }
        } catch(e) {}

        try {
          Object.defineProperty(document, 'referrer', { get: () => '', configurable: true });
        } catch(e) {}

        try {
          if (window.RTCPeerConnection) {
            const orig = window.RTCPeerConnection;
            window.RTCPeerConnection = function(config) {
              if (config && config.iceServers) { config.iceServers = []; }
              return new orig(config);
            };
            window.RTCPeerConnection.prototype = orig.prototype;
          }
        } catch(e) {}

      } catch(e) {}
    })();
    """

    static let clipboardScript: String = """
    (function() {
      try {
        if (navigator.clipboard) {
          const blocked = () => Promise.reject(new DOMException('Blocked by Hush', 'NotAllowedError'));
          navigator.clipboard.readText = blocked;
          navigator.clipboard.read = blocked;
        }
        document.addEventListener('copy', (e) => {
          try { e.stopImmediatePropagation(); } catch(e) {}
        }, true);
      } catch(e) {}
    })();
    """

    static func userScript(includeFingerprint: Bool, includeClipboard: Bool) -> [WKUserScript] {
        var scripts: [WKUserScript] = []
        if includeFingerprint {
            scripts.append(WKUserScript(source: fingerprintScript, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        }
        if includeClipboard {
            scripts.append(WKUserScript(source: clipboardScript, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        }
        return scripts
    }
}
