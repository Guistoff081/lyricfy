(() => {
  const button = document.getElementById('play-demo');
  const icon = document.getElementById('play-icon');
  const slider = document.getElementById('demo-time');
  const caption = document.getElementById('demo-caption');
  const label = document.getElementById('time-label');
  const cues = ['Na cidade que\nnunca dorme', 'Luzes riscam\no céu', 'E no silêncio', 'A noite encontra\na nossa voz'];
  let playing = false;
  let previousTime = 0;
  let frame;
  const render = () => {
    const time = Number(slider.value);
    caption.textContent = cues[Math.min(3, Math.floor(time / 4))];
    label.textContent = `00:${String(Math.floor(time)).padStart(2, '0')}`;
    slider.setAttribute('aria-valuetext', `${time.toFixed(1)} segundos`);
  };
  const pause = () => {
    playing = false;
    cancelAnimationFrame(frame);
    button.setAttribute('aria-label', 'Reproduzir prévia visual');
    button.setAttribute('aria-pressed', 'false');
    icon.setAttribute('d', 'm7 4 9 6-9 6Z');
  };
  let elapsed = 0;
  const tick = now => {
    if (!playing) return;
    elapsed += (now - previousTime) / 1000;
    previousTime = now;
    slider.value = Math.min(16, elapsed);
    render();
    if (elapsed >= 16) pause();
    else frame = requestAnimationFrame(tick);
  };
  button.addEventListener('click', () => {
    if (playing) return pause();
    if (Number(slider.value) >= 16) slider.value = 0;
    elapsed = Number(slider.value);
    playing = true;
    previousTime = performance.now();
    button.setAttribute('aria-label', 'Pausar prévia visual');
    button.setAttribute('aria-pressed', 'true');
    icon.setAttribute('d', 'M5 4h4v12H5zM12 4h4v12h-4z');
    frame = requestAnimationFrame(tick);
  });
  slider.addEventListener('input', () => { elapsed = Number(slider.value); render(); });
  document.addEventListener('visibilitychange', () => { if (document.hidden) pause(); });
  render();
})();
