import 'dart:collection';
import 'dart:convert';
import 'dart:io';

const int _port = 58987;
const int _maxHistory = 500;

Future<void> main() async {
  final history = ListQueue<String>(_maxHistory);
  final viewerClients = <WebSocket>{};

  final server = await HttpServer.bind(InternetAddress.anyIPv4, _port);

  stdout.writeln('Bloc viewer running on http://127.0.0.1:${server.port}');
  stdout.writeln(
    'Flutter app WebSocket endpoint: ws://<host-ip>:${server.port}/events',
  );

  await for (final request in server) {
    final path = request.uri.path;
    final isUpgradeRequest = WebSocketTransformer.isUpgradeRequest(request);

    stdout.writeln(
      'Incoming request: method=${request.method} path=$path upgrade=$isUpgradeRequest',
    );

    if (path == '/events' || path == 'events' || path == '/events/') {
      try {
        final socket = await WebSocketTransformer.upgrade(request);
        stdout.writeln('Flutter client connected');

        socket.listen(
          (dynamic data) {
            final text = data is String ? data : utf8.decode(data as List<int>);

            try {
              final decoded = jsonDecode(text);

              if (decoded is! Map<String, dynamic>) {
                return;
              }

              final normalized = jsonEncode(decoded);

              if (history.length == _maxHistory) {
                history.removeFirst();
              }

              history.addLast(normalized);

              for (final viewer in List<WebSocket>.from(viewerClients)) {
                viewer.add(normalized);
              }
            } catch (error) {
              stderr.writeln('Invalid event payload: $error');
            }
          },
          onDone: () => stdout.writeln('Flutter client disconnected'),
          onError: (Object error) =>
              stderr.writeln('Flutter client error: $error'),
        );

        continue;
      } catch (error) {
        stderr.writeln('Failed to upgrade Flutter client request: $error');
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('Expected WebSocket upgrade request on /events');
        await request.response.close();
        continue;
      }
    }

    if (path == '/viewer' || path == 'viewer' || path == '/viewer/') {
      try {
        final socket = await WebSocketTransformer.upgrade(request);
        viewerClients.add(socket);

        for (final event in history) {
          socket.add(event);
        }

        socket.done.whenComplete(() {
          viewerClients.remove(socket);
        });

        continue;
      } catch (error) {
        stderr.writeln('Failed to upgrade viewer request: $error');
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('Expected WebSocket upgrade request on /viewer');
        await request.response.close();
        continue;
      }
    }

    if (path.isEmpty || path == '/') {
      request.response.headers.contentType = ContentType.html;
      request.response.write(_viewerPage);
      await request.response.close();
      continue;
    }

    request.response
      ..statusCode = HttpStatus.notFound
      ..write('Not found');
    await request.response.close();
  }
}

const String _viewerPage = r'''
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Bloc Devtools Viewer</title>
  <style>
    :root {
      color-scheme: dark;
      --bg: #10141c;
      --panel: #171d29;
      --border: #2f3b4f;
      --text: #edf2ff;
      --muted: #94a3b8;
      --accent: #5eead4;
      --accent-2: #f59e0b;
      --danger: #fb7185;
      --mono: "Cascadia Code", "SFMono-Regular", Consolas, monospace;
      --sans: "Segoe UI", Inter, system-ui, sans-serif;
    }

    * { box-sizing: border-box; }
    [hidden] { display: none !important; }

    body {
      margin: 0;
      min-height: 100vh;
      background:
        radial-gradient(circle at top left, rgba(94,234,212,.12), transparent 32%),
        radial-gradient(circle at top right, rgba(245,158,11,.10), transparent 26%),
        var(--bg);
      color: var(--text);
      font-family: var(--sans);
    }

    .shell {
      display: grid;
      grid-template-columns: 380px 1fr;
      min-height: 100vh;
    }

    .sidebar, .detail {
      padding: 20px;
    }

    .sidebar {
      border-right: 1px solid var(--border);
      background: rgba(10, 14, 22, 0.45);
      backdrop-filter: blur(12px);
    }

    .detail {
      display: flex;
      flex-direction: column;
      gap: 16px;
      min-height: 0;
    }

    h1 {
      margin: 0;
      font-size: 24px;
      letter-spacing: .02em;
    }

    .subtle {
      color: var(--muted);
      margin: 6px 0 0;
    }

    .status {
      margin-top: 16px;
      padding: 10px 12px;
      border: 1px solid var(--border);
      border-radius: 14px;
      background: var(--panel);
      font-size: 14px;
    }

    .status.connected { border-color: rgba(94,234,212,.45); }
    .status.disconnected { border-color: rgba(251,113,133,.45); }

    .controls {
      display: grid;
      gap: 10px;
      margin: 18px 0;
    }

    input, button, select {
      width: 100%;
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 12px 14px;
      background: var(--panel);
      color: var(--text);
      font: inherit;
    }

    button {
      cursor: pointer;
      background: linear-gradient(135deg, rgba(94,234,212,.18), rgba(94,234,212,.08));
    }

    .summary {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 10px;
      margin-bottom: 18px;
    }

    .card {
      background: var(--panel);
      border: 1px solid var(--border);
      border-radius: 16px;
      padding: 14px;
    }

    .card strong {
      display: block;
      font-size: 28px;
      margin-top: 4px;
    }

    .events {
      display: grid;
      gap: 10px;
      max-height: calc(100vh - 320px);
      overflow: auto;
      padding-right: 4px;
    }

    .event {
      background: var(--panel);
      border: 1px solid transparent;
      border-radius: 16px;
      padding: 14px;
      cursor: pointer;
      transition: border-color .15s ease, transform .15s ease;
    }

    .event:hover,
    .event.active {
      border-color: rgba(94,234,212,.35);
      transform: translateY(-1px);
    }

    .row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
    }

    .kind {
      display: inline-flex;
      align-items: center;
      padding: 4px 10px;
      border-radius: 999px;
      font-size: 12px;
      font-weight: 700;
      letter-spacing: .04em;
      text-transform: uppercase;
    }

    .kind.transition, .kind.change { background: rgba(94,234,212,.14); color: var(--accent); }
    .kind.event, .kind.create, .kind.close { background: rgba(245,158,11,.14); color: var(--accent-2); }
    .kind.error { background: rgba(251,113,133,.14); color: var(--danger); }

    .bloc {
      margin-top: 12px;
      font-weight: 700;
    }

    .hint {
      color: var(--muted);
      font-size: 13px;
      margin-top: 6px;
      font-family: var(--mono);
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .panel {
      background: var(--panel);
      border: 1px solid var(--border);
      border-radius: 18px;
      padding: 16px;
      min-height: 0;
      overflow: auto;
    }

    .detail-tabs {
      display: flex;
      gap: 8px;
      margin-top: -4px;
    }

    .tab-shell {
      display: flex;
      flex-direction: column;
      flex: 1;
      min-height: 0;
      overflow: hidden;
      padding: 0;
    }

    .tab-button {
      width: auto;
      background: transparent;
      border: 1px solid transparent;
      color: var(--muted);
      padding: 10px 12px;
    }

    .tab-button.active {
      color: var(--text);
      border-color: rgba(94,234,212,.25);
      background: rgba(94,234,212,.08);
    }

    .tab-button[hidden] {
      display: none !important;
    }

    .tab-panel {
      padding: 16px;
      min-height: 0;
      overflow: auto;
      flex: 1;
    }

    .tab-panel-grid {
      display: grid;
      grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
      gap: 16px;
    }

    .tab-section {
      background: rgba(255,255,255,.02);
      border: 1px solid var(--border);
      border-radius: 16px;
      padding: 16px;
      min-height: 0;
      overflow: auto;
    }

    .json-view {
      font-family: var(--mono);
      font-size: 13px;
      line-height: 1.45;
      word-break: break-word;
      overflow-wrap: anywhere;
    }

    .json-row {
      padding-left: 12px;
      border-left: 1px solid rgba(148,163,184,.16);
      margin-left: 6px;
    }

    .json-leaf {
      padding: 2px 0;
    }

    .json-key {
      color: var(--accent);
    }

    .json-meta {
      color: var(--muted);
    }

    .json-value-string {
      color: #c4f1be;
    }

    .json-value-number {
      color: #f9c97c;
    }

    .json-value-boolean {
      color: #93c5fd;
    }

    .json-value-null {
      color: var(--danger);
    }

    details.json-node {
      margin: 2px 0;
    }

    details.json-node > summary {
      list-style: none;
      cursor: pointer;
      display: flex;
      align-items: baseline;
      gap: 8px;
      padding: 2px 0;
    }

    details.json-node > summary::-webkit-details-marker {
      display: none;
    }

    details.json-node > summary::before {
      content: ">";
      color: var(--muted);
      display: inline-block;
      transform: rotate(0deg);
      transition: transform .12s ease;
      font-size: 11px;
    }

    details.json-node[open] > summary::before {
      transform: rotate(90deg);
    }

    .json-children {
      margin-top: 4px;
    }

    .diff-view {
      font-family: var(--mono);
      font-size: 13px;
      line-height: 1.45;
      word-break: break-word;
      overflow-wrap: anywhere;
    }

    .diff-row {
      padding: 8px 10px;
      border-radius: 10px;
      margin: 6px 0;
      border: 1px solid var(--border);
      background: rgba(255,255,255,.02);
    }

    .diff-row.added {
      border-color: rgba(94,234,212,.25);
      background: rgba(94,234,212,.08);
    }

    .diff-row.removed {
      border-color: rgba(251,113,133,.25);
      background: rgba(251,113,133,.08);
    }

    .diff-row.changed {
      border-color: rgba(245,158,11,.25);
      background: rgba(245,158,11,.08);
    }

    .diff-path {
      color: var(--accent);
      margin-bottom: 4px;
    }

    .diff-meta {
      color: var(--muted);
    }

    .diff-empty {
      color: var(--muted);
    }

    .empty {
      display: grid;
      place-items: center;
      color: var(--muted);
      min-height: 220px;
      border: 1px dashed var(--border);
      border-radius: 18px;
      background: rgba(23,29,41,.6);
    }

    @media (max-width: 960px) {
      .shell { grid-template-columns: 1fr; }
      .sidebar { border-right: 0; border-bottom: 1px solid var(--border); }
      .events { max-height: 360px; }
      .tab-panel-grid { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>
  <div class="shell">
    <aside class="sidebar">
      <h1>Bloc Viewer</h1>
      <p class="subtle">Timeline de eventos, cambios y transiciones recibidos por WebSocket.</p>
      <div id="status" class="status disconnected">Disconnected</div>
      <div class="controls">
        <input id="search" type="search" placeholder="Filtrar por bloc o kind" />
        <select id="blocFilter">
          <option value="">Todos los blocs</option>
        </select>
        <button id="clearButton" type="button">Limpiar timeline</button>
      </div>
      <div class="summary">
        <div class="card">
          <span class="subtle">Eventos visibles</span>
          <strong id="visibleCount">0</strong>
        </div>
        <div class="card">
          <span class="subtle">Blocs activos</span>
          <strong id="blocCount">0</strong>
        </div>
      </div>
      <div id="events" class="events"></div>
    </aside>
    <main class="detail">
      <div class="card">
        <div class="row">
          <div>
            <div class="subtle">Detalle</div>
            <strong id="detailTitle">Selecciona un evento</strong>
          </div>
          <span id="detailKind" class="kind">Idle</span>
        </div>
      </div>
      <div id="detailTabs" class="detail-tabs" hidden>
        <button id="payloadTab" class="tab-button active" type="button">Payload</button>
        <button id="appStateTab" class="tab-button" type="button">App State</button>
        <button id="diffTab" class="tab-button" type="button" hidden>Diff</button>
      </div>
      <div id="emptyState" class="empty">Todavia no hay eventos para mostrar.</div>
      <section id="detailGrid" class="panel tab-shell" hidden>
        <div id="payloadPanelWrap" class="tab-panel">
          <div class="tab-panel-grid">
            <section class="tab-section">
              <div class="subtle">Resumen</div>
              <div id="summaryPanel" class="json-view"></div>
            </section>
            <section class="tab-section">
              <div class="subtle">Payload</div>
              <div id="payloadPanel" class="json-view"></div>
            </section>
          </div>
        </div>
        <div id="appStatePanelWrap" class="tab-panel" hidden>
          <div class="subtle">App State</div>
          <div id="appStatePanel" class="json-view"></div>
        </div>
        <div id="diffPanelWrap" class="tab-panel" hidden>
          <div class="subtle">Diff</div>
          <div id="diffPanel" class="diff-view"></div>
        </div>
      </section>
    </main>
  </div>

  <script>
    const events = [];
    let selectedSequence = null;
    let activeTab = 'payload';

    const statusEl = document.getElementById('status');
    const searchEl = document.getElementById('search');
    const blocFilterEl = document.getElementById('blocFilter');
    const clearButtonEl = document.getElementById('clearButton');
    const eventsEl = document.getElementById('events');
    const visibleCountEl = document.getElementById('visibleCount');
    const blocCountEl = document.getElementById('blocCount');
    const detailTitleEl = document.getElementById('detailTitle');
    const detailKindEl = document.getElementById('detailKind');
    const summaryPanelEl = document.getElementById('summaryPanel');
    const payloadPanelEl = document.getElementById('payloadPanel');
    const appStatePanelEl = document.getElementById('appStatePanel');
    const payloadTabEl = document.getElementById('payloadTab');
    const appStateTabEl = document.getElementById('appStateTab');
    const diffTabEl = document.getElementById('diffTab');
    const payloadPanelWrapEl = document.getElementById('payloadPanelWrap');
    const appStatePanelWrapEl = document.getElementById('appStatePanelWrap');
    const diffPanelWrapEl = document.getElementById('diffPanelWrap');
    const detailTabsEl = document.getElementById('detailTabs');
    const emptyStateEl = document.getElementById('emptyState');
    const detailGridEl = document.getElementById('detailGrid');
    const diffPanelEl = document.getElementById('diffPanel');

    function escapeHtml(value) {
      return String(value)
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
    }

    function valueClass(value) {
      if (value === null) return 'json-value-null';
      if (typeof value === 'string') return 'json-value-string';
      if (typeof value === 'number') return 'json-value-number';
      if (typeof value === 'boolean') return 'json-value-boolean';
      return 'json-meta';
    }

    function formatPrimitive(value) {
      if (value === null) return 'null';
      if (typeof value === 'string') return `"${escapeHtml(value)}"`;
      return escapeHtml(value);
    }

    function renderJson(value, key = null, expanded = true) {
      const isArray = Array.isArray(value);
      const isObject = value !== null && typeof value === 'object';

      if (!isObject) {
        return `
          <div class="json-leaf">
            ${key !== null ? `<span class="json-key">${escapeHtml(key)}</span>: ` : ''}
            <span class="${valueClass(value)}">${formatPrimitive(value)}</span>
          </div>
        `;
      }

      const entries = isArray
        ? value.map((item, index) => [index, item])
        : Object.entries(value);

      const label = isArray ? `Array(${entries.length})` : `Object(${entries.length})`;
      const children = entries
        .map(([childKey, childValue]) => renderJson(childValue, String(childKey), false))
        .join('');

      return `
        <details class="json-node"${expanded ? ' open' : ''}>
          <summary>
            ${key !== null ? `<span class="json-key">${escapeHtml(key)}</span>` : '<span class="json-key">root</span>'}
            <span class="json-meta">${label}</span>
          </summary>
          <div class="json-children json-row">
            ${children || '<div class="json-meta">empty</div>'}
          </div>
        </details>
      `;
    }

    function renderJsonInto(element, value, expanded = true) {
      element.innerHTML = renderJson(value, null, expanded);
    }

    function serializeInline(value) {
      if (value === null) return 'null';
      if (typeof value === 'string') return `"${escapeHtml(value)}"`;
      if (typeof value === 'number' || typeof value === 'boolean') return escapeHtml(value);
      if (Array.isArray(value)) return `Array(${value.length})`;
      if (typeof value === 'object') return `Object(${Object.keys(value).length})`;
      return escapeHtml(String(value));
    }

    function buildDiffRows(currentValue, nextValue, path = 'state') {
      if (JSON.stringify(currentValue) === JSON.stringify(nextValue)) {
        return [];
      }

      const currentIsObject = currentValue !== null && typeof currentValue === 'object';
      const nextIsObject = nextValue !== null && typeof nextValue === 'object';

      if (currentIsObject && nextIsObject) {
        const currentEntries = Array.isArray(currentValue)
          ? currentValue.map((value, index) => [String(index), value])
          : Object.entries(currentValue);
        const nextEntries = Array.isArray(nextValue)
          ? nextValue.map((value, index) => [String(index), value])
          : Object.entries(nextValue);

        const currentMap = new Map(currentEntries);
        const nextMap = new Map(nextEntries);
        const keys = [...new Set([...currentMap.keys(), ...nextMap.keys()])];
        const rows = [];

        for (const key of keys) {
          const childPath = Array.isArray(nextValue) || Array.isArray(currentValue)
            ? `${path}[${key}]`
            : `${path}.${key}`;

          if (!currentMap.has(key)) {
            rows.push(`
              <div class="diff-row added">
                <div class="diff-path">${escapeHtml(childPath)}</div>
                <div><span class="diff-meta">added:</span> ${serializeInline(nextMap.get(key))}</div>
              </div>
            `);
            continue;
          }

          if (!nextMap.has(key)) {
            rows.push(`
              <div class="diff-row removed">
                <div class="diff-path">${escapeHtml(childPath)}</div>
                <div><span class="diff-meta">removed:</span> ${serializeInline(currentMap.get(key))}</div>
              </div>
            `);
            continue;
          }

          rows.push(...buildDiffRows(currentMap.get(key), nextMap.get(key), childPath));
        }

        if (rows.length) {
          return rows;
        }
      }

      return [`
        <div class="diff-row changed">
          <div class="diff-path">${escapeHtml(path)}</div>
          <div><span class="diff-meta">from:</span> ${serializeInline(currentValue)}</div>
          <div><span class="diff-meta">to:</span> ${serializeInline(nextValue)}</div>
        </div>
      `];
    }

    function renderDiffInto(element, currentValue, nextValue) {
      const rows = buildDiffRows(currentValue, nextValue);
      element.innerHTML = rows.length
        ? rows.join('')
        : '<div class="diff-empty">No differences</div>';
    }

    function setActiveTab(tab) {
      const diffAvailable = !diffTabEl.hidden;
      if (tab === 'diff' && !diffAvailable) {
        tab = 'payload';
      }

      activeTab = tab;
      payloadTabEl.classList.toggle('active', tab === 'payload');
      appStateTabEl.classList.toggle('active', tab === 'appState');
      diffTabEl.classList.toggle('active', tab === 'diff');
      payloadPanelWrapEl.hidden = tab !== 'payload';
      appStatePanelWrapEl.hidden = tab !== 'appState';
      diffPanelWrapEl.hidden = tab !== 'diff';
    }

    function connect() {
      const socket = new WebSocket(`ws://${location.host}/viewer`);

      socket.addEventListener('open', () => {
        statusEl.textContent = 'Connected';
        statusEl.className = 'status connected';
      });

      socket.addEventListener('close', () => {
        statusEl.textContent = 'Disconnected';
        statusEl.className = 'status disconnected';
        window.setTimeout(connect, 1500);
      });

      socket.addEventListener('message', (message) => {
        const event = JSON.parse(message.data);
        events.push(event);
        updateBlocFilter();
        render();
      });
    }

    function updateBlocFilter() {
      const blocs = [...new Set(events.map((event) => event.bloc))].sort();
      const currentValue = blocFilterEl.value;
      blocFilterEl.innerHTML = '<option value="">Todos los blocs</option>';

      for (const bloc of blocs) {
        const option = document.createElement('option');
        option.value = bloc;
        option.textContent = bloc;
        blocFilterEl.append(option);
      }

      blocFilterEl.value = blocs.includes(currentValue) ? currentValue : '';
      blocCountEl.textContent = String(blocs.length);
    }

    function getVisibleEvents() {
      const query = searchEl.value.trim().toLowerCase();
      const blocFilter = blocFilterEl.value;

      return [...events]
        .reverse()
        .filter((event) => {
          const matchesBloc = !blocFilter || event.bloc === blocFilter;
          const haystack = `${event.bloc} ${event.kind}`.toLowerCase();
          const matchesQuery = !query || haystack.includes(query);
          return matchesBloc && matchesQuery;
        });
    }

    function render() {
      const visibleEvents = getVisibleEvents();
      visibleCountEl.textContent = String(visibleEvents.length);
      eventsEl.innerHTML = '';

      if (!visibleEvents.length) {
        selectedSequence = null;
      } else if (!visibleEvents.some((event) => event.sequence === selectedSequence)) {
        selectedSequence = visibleEvents[0].sequence;
      }

      for (const event of visibleEvents) {
        const node = document.createElement('button');
        node.type = 'button';
        node.className = `event ${selectedSequence === event.sequence ? 'active' : ''}`;

        const hint = event.event?.type || event.nextState?.type || event.state?.type || '';

        node.innerHTML = `
          <div class="row">
            <span class="kind ${event.kind}">${event.kind}</span>
            <span class="subtle">#${event.sequence}</span>
          </div>
          <div class="bloc">${event.bloc}</div>
          <div class="hint">${hint}</div>
        `;

        node.addEventListener('click', () => {
          selectedSequence = event.sequence;
          render();
          renderDetail(event);
        });

        eventsEl.append(node);
      }

      if (!visibleEvents.length) {
        eventsEl.innerHTML = '<div class="empty">No hay eventos con el filtro actual.</div>';
        detailTitleEl.textContent = 'Selecciona un evento';
        detailKindEl.textContent = 'Idle';
        detailKindEl.className = 'kind';
        summaryPanelEl.innerHTML = '';
        payloadPanelEl.innerHTML = '';
        appStatePanelEl.innerHTML = '';
        diffPanelEl.innerHTML = '';
        diffTabEl.hidden = true;
        setActiveTab('payload');
        emptyStateEl.hidden = false;
        detailTabsEl.hidden = true;
        detailGridEl.hidden = true;
        return;
      }

      const selected = events.find((event) => event.sequence === selectedSequence);

      if (selected) {
        renderDetail(selected);
      } else {
        emptyStateEl.hidden = false;
        detailTabsEl.hidden = true;
        detailGridEl.hidden = true;
      }
    }

    function renderDetail(event) {
      emptyStateEl.hidden = true;
      detailTabsEl.hidden = false;
      detailGridEl.hidden = false;
      detailTitleEl.textContent = `${event.bloc} #${event.sequence}`;
      detailKindEl.textContent = event.kind;
      detailKindEl.className = `kind ${event.kind}`;

      renderJsonInto(summaryPanelEl, {
        bloc: event.bloc,
        kind: event.kind,
        timestamp: event.timestamp,
        eventType: event.event?.type ?? null,
        currentState: event.currentState?.type ?? event.state?.type ?? null,
        nextState: event.nextState?.type ?? null
      }, true);

      renderJsonInto(payloadPanelEl, event, true);
      renderJsonInto(appStatePanelEl, event.appState ?? {}, true);
      const diffAvailable = event.currentState !== undefined && event.nextState !== undefined;
      diffTabEl.hidden = !diffAvailable;
      if (diffAvailable) {
        renderDiffInto(diffPanelEl, event.currentState, event.nextState);
      } else {
        diffPanelEl.innerHTML = '<div class="diff-empty">Diff not available for this event type</div>';
      }
      setActiveTab(activeTab);
    }

    searchEl.addEventListener('input', render);
    blocFilterEl.addEventListener('change', render);
    payloadTabEl.addEventListener('click', () => setActiveTab('payload'));
    appStateTabEl.addEventListener('click', () => setActiveTab('appState'));
    diffTabEl.addEventListener('click', () => setActiveTab('diff'));
    clearButtonEl.addEventListener('click', () => {
      events.length = 0;
      selectedSequence = null;
      updateBlocFilter();
      render();
      detailTitleEl.textContent = 'Selecciona un evento';
      detailKindEl.textContent = 'Idle';
      detailKindEl.className = 'kind';
      summaryPanelEl.innerHTML = '';
      payloadPanelEl.innerHTML = '';
      appStatePanelEl.innerHTML = '';
      diffPanelEl.innerHTML = '';
      diffTabEl.hidden = true;
      setActiveTab('payload');
      emptyStateEl.hidden = false;
      detailTabsEl.hidden = true;
      detailGridEl.hidden = true;
    });

    setActiveTab('payload');
    connect();
    render();
  </script>
</body>
</html>
''';
