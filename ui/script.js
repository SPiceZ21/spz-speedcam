'use strict';

const flash       = document.getElementById('flash');
const capture     = document.getElementById('capture');
const speedValue  = document.getElementById('speed-value');
const speedUnit   = document.getElementById('speed-unit');
const camLocation = document.getElementById('cam-location');
const badges      = document.getElementById('badges');
const dismissBar  = document.getElementById('dismiss-progress');
const recordPanel = document.getElementById('records-panel');
const recordsList = document.getElementById('records-list');

let dismissTimer  = null;
let cardUnit      = 'KM/H';

// ── Helpers ───────────────────────────────────────────────────────────────────

function svgIcon(path, size = 14) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">${path}</svg>`;
}

const ICONS = {
  camera: svgIcon('<path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/>', 16),
  trophy: svgIcon('<path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6"/><path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18"/><path d="M4 22h16"/><path d="M10 14.66V17c0 .55-.47.98-.97 1.21C7.85 18.75 7 20.24 7 22"/><path d="M14 14.66V17c0 .55.47.98.97 1.21C16.15 18.75 17 20.24 17 22"/><path d="M18 2H6v7a6 6 0 0 0 12 0V2z"/>'),
  star:   svgIcon('<polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>'),
  arrow:  svgIcon('<line x1="12" y1="5" x2="12" y2="19"/><polyline points="19 12 12 19 5 12"/>'),
  close:  svgIcon('<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>'),
};

// ── Capture card ──────────────────────────────────────────────────────────────

function showCapture(data) {
  cardUnit = data.unit || 'KM/H';

  // Flash
  flash.classList.remove('fire');
  void flash.offsetWidth; // reflow
  flash.classList.add('fire');

  // Speed colour by value
  const spd = data.speed || 0;
  speedValue.className = 'speed-value';
  if (spd >= 200) speedValue.classList.add('sonic');
  else if (spd >= 130) speedValue.classList.add('fast');

  speedValue.textContent = spd;
  speedUnit.textContent  = cardUnit;
  camLocation.textContent = data.cameraName || 'Unknown Location';

  // World-record tag — floats ABOVE the box, not inside it
  const capGlobal = document.getElementById('cap-global');
  if (data.globalRecord) {
    capGlobal.innerHTML = ICONS.trophy + ' NEW WORLD RECORD';
    capGlobal.classList.add('show');
  } else {
    capGlobal.innerHTML = '';
    capGlobal.classList.remove('show');
  }

  // Badges (inside the box)
  badges.innerHTML = '';

  if (data.personalBest && !data.globalRecord) {
    const b = document.createElement('div');
    b.className = 'badge badge-personal';
    b.innerHTML = ICONS.star + ' NEW PERSONAL BEST';
    badges.appendChild(b);
  }

  if (data.prevBest && !data.personalBest) {
    const diff = spd - data.prevBest;
    const b = document.createElement('div');
    b.className = 'badge badge-improvement';
    b.innerHTML = ICONS.arrow + ` Personal best: ${data.prevBest} ${cardUnit}`;
    badges.appendChild(b);
  }

  // Show card
  capture.classList.remove('hiding');
  capture.classList.add('visible');

  // Dismiss progress bar
  const duration = data.duration || 6000;
  dismissBar.style.transition = 'none';
  dismissBar.style.width = '100%';
  void dismissBar.offsetWidth;
  dismissBar.style.transition = `width ${duration}ms linear`;
  dismissBar.style.width = '0%';

  // Auto-dismiss
  if (dismissTimer) clearTimeout(dismissTimer);
  dismissTimer = setTimeout(hideCapture, duration);
}

function hideCapture() {
  capture.classList.remove('visible');
  capture.classList.add('hiding');
  const capGlobal = document.getElementById('cap-global');
  if (capGlobal) capGlobal.classList.remove('show');
  dismissTimer = null;
}

// ── Records panel ─────────────────────────────────────────────────────────────

function showRecords(data) {
  const records = data.records || [];

  recordsList.innerHTML = '';

  if (records.length === 0) {
    recordsList.innerHTML = '<div class="empty-msg">No personal bests recorded yet.<br>Get caught speeding to set records.</div>';
  } else {
    records.forEach(rec => {
      const cam  = (data.cameraList || []).find(c => c.id === rec.camera_id);
      const name = cam ? cam.name : rec.camera_id;
      const spd  = Math.floor(cardUnit === 'MPH' ? rec.speed_kmh * 0.621371 : rec.speed_kmh);
      const date = rec.updated_at ? rec.updated_at.slice(0, 10) : '';

      const row = document.createElement('div');
      row.className = 'record-row';
      row.innerHTML = `
        <div class="record-cam">
          <div class="record-cam-name">${name}</div>
          <div class="record-cam-date">${date}</div>
        </div>
        <div class="record-speed">${spd}<span>${cardUnit}</span></div>
      `;
      recordsList.appendChild(row);
    });
  }

  recordPanel.classList.add('visible');
}

function hideRecords() {
  recordPanel.classList.remove('visible');
  fetch(`https://${GetParentResourceName()}/closeRecords`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({}),
  }).catch(() => {});
}

// ── Message handler ───────────────────────────────────────────────────────────

window.addEventListener('message', e => {
  const msg = e.data;
  if (!msg || !msg.type) return;

  switch (msg.type) {
    case 'capture':
      showCapture(msg);
      break;
    case 'openRecords':
      // panel shown after records data arrives
      break;
    case 'records':
      showRecords(msg);
      break;
    case 'closeRecords':
      hideRecords();
      break;
  }
});

// Close records on Escape
document.addEventListener('keydown', e => {
  if (e.key === 'Escape' && recordPanel.classList.contains('visible')) {
    hideRecords();
  }
});

// Close btn
document.getElementById('close-records-btn').addEventListener('click', hideRecords);

// ── Browser preview (no FiveM) ──────────────────────────────────────────────
// Open index.html directly in a browser to preview. Buttons re-trigger the
// card / records with mock data. Does nothing inside the FiveM NUI.
(function () {
  const inNui = typeof GetParentResourceName === 'function';
  if (inNui) return;

  document.body.style.pointerEvents = 'auto';
  document.body.style.background = '#11161d';   // stand-in backdrop

  const MOCK_CAPTURE = {
    type: 'capture',
    cameraName: 'Vespucci Blvd',
    speed: 168,
    unit: 'KM/H',
    personalBest: true,
    globalRecord: false,
    prevBest: 152,
    duration: 6000,
  };

  const MOCK_RECORDS = {
    type: 'records',
    cameraList: [
      { id: 'speedcam_vespucci_bvd', name: 'Vespucci Blvd' },
      { id: 'speedcam_richman',      name: 'Richman' },
      { id: 'speedcam_route68',      name: 'Route 68' },
    ],
    records: [
      { camera_id: 'speedcam_route68',      speed_kmh: 214.6, updated_at: '2026-07-12' },
      { camera_id: 'speedcam_vespucci_bvd', speed_kmh: 168.2, updated_at: '2026-07-13' },
      { camera_id: 'speedcam_richman',      speed_kmh: 133.9, updated_at: '2026-07-10' },
    ],
  };

  function bar(label, onClick) {
    const b = document.createElement('button');
    b.textContent = label;
    b.style.cssText =
      'font:600 12px/1 sans-serif;padding:8px 12px;margin:0 6px 0 0;' +
      'background:#FF6200;color:#000;border:0;border-radius:5px;cursor:pointer;';
    b.onclick = onClick;
    return b;
  }

  const dock = document.createElement('div');
  dock.style.cssText = 'position:fixed;top:12px;left:12px;z-index:9999;pointer-events:auto;';
  dock.appendChild(bar('▶ Capture',  () => showCapture(MOCK_CAPTURE)));
  dock.appendChild(bar('★ Global',   () => showCapture({ ...MOCK_CAPTURE, cameraName: 'Route 68', speed: 231, globalRecord: true, personalBest: false })));
  dock.appendChild(bar('🏁 Records',  () => showRecords(MOCK_RECORDS)));
  dock.appendChild(bar('✕ Hide',     () => { hideCapture(); recordPanel.classList.remove('visible'); }));
  document.body.appendChild(dock);

  // records close button + Esc work without the NUI fetch
  window.GetParentResourceName = window.GetParentResourceName || (() => 'preview');

  // Auto-show the capture once on load
  setTimeout(() => showCapture(MOCK_CAPTURE), 400);
})();
