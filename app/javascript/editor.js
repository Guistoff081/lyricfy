const root = document.getElementById('lyric-editor');
if (root) {
  const media = document.getElementById('media-preview');
  const source = document.getElementById('project_subtitle_text');
  const rows = document.getElementById('cue-rows');
  const message = document.getElementById('editor-message');
  const saveStatus = document.getElementById('subtitle-save-status');
  const duration = Number(root.dataset.duration);
  let cues = [], selected = -1, dirty = false, mode = 'lines', trackURL;
  const time = value => {
    const m = value.match(/^(\d{2,}):([0-5]\d):([0-5]\d),(\d{3})$/);
    if (!m) throw new Error('Use o tempo no formato 00:00:00,000.');
    return ((+m[1] * 60 + +m[2]) * 60 + +m[3]) * 1000 + +m[4];
  };
  const stamp = ms => {
    const n = Math.round(ms);
    return `${String(Math.floor(n / 3600000)).padStart(2,'0')}:${String(Math.floor(n / 60000) % 60).padStart(2,'0')}:${String(Math.floor(n / 1000) % 60).padStart(2,'0')},${String(n % 1000).padStart(3,'0')}`;
  };
  const validate = list => {
    let end = 0;
    list.forEach((cue, i) => {
      if (cue.start < end || cue.end <= cue.start || cue.end > duration * 1000 + 100 || !cue.text.trim()) throw new Error(`Revise a linha ${i+1}: texto obrigatório, tempos crescentes, sem sobreposição e dentro da mídia.`);
      end = cue.end;
    });
    return list;
  };
  const renumber = text => {
    let index = 0;
    return text.replace(/(^\uFEFF?|\r?\n[ \t]*\r?\n)([ \t]*)\d+([ \t]*)(?=\r?\n|$)/g,
      (_, prefix, before, after) => `${prefix}${before}${++index}${after}`);
  };
  const normalizeNumbers = () => {
    const normalized = renumber(source.value);
    if (normalized !== source.value) {
      source.value = normalized;
      markDirty();
    }
  };
  const parse = text => {
    const normalized = text.replace(/^\uFEFF/, '').replace(/\r\n/g, '\n').trim();
    if (!normalized) return [];
    return validate(normalized.split(/\n[ \t]*\n/).map(block => {
      const lines = block.split('\n');
      if (!/^\d+$/.test(lines.shift())) throw new Error('Cada bloco SRT deve começar com um número.');
      const parts = (lines.shift() || '').split(' --> ');
      if (parts.length !== 2) throw new Error('Separe início e fim com " --> ".');
      return {start: time(parts[0]), end: time(parts[1]), text: lines.join('\n')};
    }));
  };
  const serialize = list => list.map((c,i) => `${i+1}\n${stamp(c.start)} --> ${stamp(c.end)}\n${c.text}\n`).join('\n');
  const markDirty = () => { dirty = true; saveStatus.textContent = 'Alterações não salvas.'; };
  const position = document.getElementById('project_subtitle_position');
  const stage = root.querySelector('.media-stage');
  const font = document.getElementById('project_subtitle_font');
  const size = document.getElementById('project_subtitle_size');
  const positionPreview = () => {
    stage.dataset.subtitlePosition = position.value;
    const caption = document.getElementById('video-caption') || document.getElementById('audio-caption');
    caption.style.fontFamily = font.value;
    let previewHeight = root.querySelector('.audio-display')?.clientHeight || media.clientHeight;
    if (media.tagName === 'VIDEO' && media.videoWidth) {
      const scale = Math.min(media.clientWidth / media.videoWidth, media.clientHeight / media.videoHeight);
      const height = media.videoHeight * scale;
      previewHeight = height;
      const inset = (media.clientHeight - height) / 2;
      // Match libass's 20px vertical margin on its default 288px script height.
      stage.style.setProperty('--caption-edge', `${inset + height * 20 / 288}px`);
    }
    if (size.validity.valid) caption.style.fontSize = `${Number(size.value) * previewHeight / 288}px`;
  };
  for (const control of [font, size]) control.addEventListener('input', () => { positionPreview(); markDirty(); });
  position.addEventListener('change', () => { positionPreview(); markDirty(); });
  media.addEventListener('loadedmetadata', positionPreview);
  new ResizeObserver(positionPreview).observe(media);
  positionPreview();
  const showError = error => { message.textContent = error.message; };
  const highlight = () => {
    const now = media.currentTime * 1000;
    Array.from(rows.children).forEach((row,i) => {
      row.classList.toggle('selected', i === selected);
      row.classList.toggle('playing', now >= cues[i].start && now < cues[i].end);
    });
    const caption = document.getElementById('audio-caption') || document.getElementById('video-caption');
    if (caption) caption.textContent = cues.find(c => now >= c.start && now < c.end)?.text || '';
  };
  const preview = () => {
    if (media.tagName === 'VIDEO') {
      const track = media.querySelector('track');
      if (trackURL) URL.revokeObjectURL(trackURL);
      // Caption text is plain text. Escape WebVTT markup while retaining line breaks.
      const safe = text => text.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
      const vtt = 'WEBVTT\n\n' + cues.map(c => `${stamp(c.start).replace(',','.')} --> ${stamp(c.end).replace(',','.')}\n${safe(c.text)}\n`).join('\n');
      trackURL = URL.createObjectURL(new Blob([vtt], {type:'text/vtt'}));
      track.src = trackURL; track.track.mode = 'hidden';
    }
    highlight();
  };
  const renderRows = () => {
    rows.replaceChildren();
    cues.forEach((cue, i) => {
      const tr = document.createElement('tr');
      const first = document.createElement('td');
      const jump = document.createElement('button'); jump.type='button'; jump.className='cue-number'; jump.textContent=String(i+1); jump.setAttribute('aria-label',`Reproduzir linha ${i+1}`);
      jump.onclick=()=>{selected=i; media.currentTime=cues[i].start/1000; highlight();};first.append(jump);tr.append(first);
      for (const key of ['start','end','text']) {
        const td=document.createElement('td');const input=document.createElement(key==='text'?'textarea':'input');
        input.className=key==='text'?'textarea':'input';input.value=key==='text'?cue.text:stamp(cue[key]);input.setAttribute('aria-label',`${key==='start'?'Início':key==='end'?'Fim':'Texto'} da linha ${i+1}`);
        if(key==='text') input.rows=2;
        input.addEventListener('focus',()=>{selected=i;highlight();});
        input.addEventListener('input',()=>{
          markDirty();
          // Preserve even invalid edits in the canonical SRT, so validation never silently discards them.
          source.value=Array.from(rows.children).map((r,j)=>{const fields=r.querySelectorAll('input,textarea');return `${j+1}\n${fields[0].value} --> ${fields[1].value}\n${fields[2].value}\n`;}).join('\n');
          try {cues=parse(source.value);message.textContent='';preview();} catch(e){showError(e);}
        });td.append(input);tr.append(td);
      }
      const td=document.createElement('td');const remove=document.createElement('button');remove.type='button';remove.className='cue-delete';remove.setAttribute('aria-label',`Remover linha ${i+1}`);
      const img=document.createElement('img');img.src='/icons/x.svg';img.alt='';img.className='studio-icon';remove.append(img);
      remove.onclick=()=>{try{cues=parse(source.value);cues.splice(i,1);selected=-1;commit();}catch(e){showError(e);}};td.append(remove);tr.append(td);rows.append(tr);
    }); highlight();
  };
  const commit = () => {validate(cues);source.value=serialize(cues);markDirty();message.textContent='';renderRows();preview();};
  const switchMode = next => {
    if(next==='lines') {normalizeNumbers();try{cues=parse(source.value);renderRows();preview();message.textContent='';}catch(e){showError(e);return;}}
    mode=next;
    for(const name of ['lines','srt']) {document.getElementById(`${name}-panel`).hidden=name!==next;const tab=document.getElementById(`${name}-tab`);tab.classList.toggle('tab-active',name===next);tab.setAttribute('aria-selected',name===next?'true':'false');}
  };
  document.getElementById('lines-tab').onclick=()=>switchMode('lines');
  document.getElementById('srt-tab').onclick=()=>switchMode('srt');
  source.addEventListener('change',()=>{normalizeNumbers();try{cues=parse(source.value);preview();message.textContent='';}catch(e){showError(e);}});
  source.addEventListener('input',()=>{markDirty();try{cues=parse(source.value);preview();message.textContent='';}catch(e){showError(e);}});
  document.getElementById('add-cue').onclick=()=>{try{cues=parse(source.value);const start=cues.at(-1)?.end || 0;const end=Math.min(start+3000, Math.floor(duration*1000));if(end<=start)throw new Error('Não há tempo livre após a última linha. Ajuste seu fim primeiro.');cues.push({start,end,text:'Nova legenda'});selected=cues.length-1;commit();rows.lastElementChild?.scrollIntoView({block:'nearest'});}catch(e){showError(e);}};
  for(const [id,delta] of [['shift-back',-500],['shift-forward',500]]) document.getElementById(id).onclick=()=>{try{const updated=parse(source.value);if(selected<0||!updated[selected])throw new Error('Selecione uma linha para ajustar o tempo.');updated[selected].start+=delta;updated[selected].end+=delta;validate(updated);cues=updated;commit();}catch(e){showError(e);}};
  document.getElementById('seek-button').onclick=()=>{const value=Number(document.getElementById('seek-time').value);if(Number.isFinite(value)&&value>=0&&value<=duration){media.currentTime=value;message.textContent='';}else showError(new Error('Informe um tempo dentro da mídia.'));};
  media.addEventListener('timeupdate',highlight);
  document.getElementById('srt-import').addEventListener('change',async e=>{const file=e.target.files[0];if(!file)return;try{if(file.size>2*1024*1024)throw new Error('Use um SRT de até 2 MB.');const text=await file.text();cues=parse(text);source.value=serialize(cues);markDirty();renderRows();preview();message.textContent=`${file.name} importado. Salve para exportar.`;}catch(error){showError(error);}e.target.value='';});
  document.getElementById('subtitle-form').addEventListener('submit',e=>{try{normalizeNumbers();parse(source.value);dirty=false;}catch(error){e.preventDefault();showError(error);}});
  document.getElementById('export-form').addEventListener('submit',e=>{if(dirty){e.preventDefault();showError(new Error('Salve a legenda antes de exportar para incluir suas alterações.'));document.getElementById('subtitle-save-status').scrollIntoView({block:'center'});}});
  window.addEventListener('beforeunload',e=>{if(dirty){e.preventDefault();e.returnValue='';}});
  try {cues=parse(source.value);renderRows();preview();}catch(e){switchMode('srt');showError(e);}
}
