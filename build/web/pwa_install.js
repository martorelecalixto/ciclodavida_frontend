let deferredPrompt;
let isInstalled = false;

window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault();
  deferredPrompt = e;

  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler('pwaAvailable');
  }
});

window.addEventListener('appinstalled', () => {
  isInstalled = true;

  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler('pwaInstalled');
  }
});

window.triggerPWAInstall = async () => {
  if (!deferredPrompt) return;

  deferredPrompt.prompt();
  const result = await deferredPrompt.userChoice;
  deferredPrompt = null;

  return result.outcome;
};

window.isPWAInstalled = () => {
  return window.matchMedia('(display-mode: standalone)').matches || isInstalled;
};