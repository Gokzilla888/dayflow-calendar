import 'package:flutter/material.dart';

void main() => runApp(const DayflowApp());

class DayflowApp extends StatelessWidget {
  const DayflowApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6C5CE7);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dayflow',
      themeMode: ThemeMode.system,
      theme: _theme(Brightness.light, seed),
      darkTheme: _theme(Brightness.dark, seed),
      home: const CalendarHomePage(),
    );
  }

  ThemeData _theme(Brightness brightness, Color seed) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          brightness == Brightness.dark ? const Color(0xFF101014) : const Color(0xFFF7F6FB),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}

enum CalendarView { month, agenda }

class CalendarHomePage extends StatefulWidget {
  const CalendarHomePage({super.key});

  @override
  State<CalendarHomePage> createState() => _CalendarHomePageState();
}

class _CalendarHomePageState extends State<CalendarHomePage> {
  CalendarView _view = CalendarView.month;
  DateTime _focusedMonth = DateTime(2026, 11);
  DateTime _selected = DateTime(2026, 11, 11);

  static const _weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final List<CalendarEntry> _entries = const [
    CalendarEntry(11, 'Project planning', '10:00 – 11:00', EntryKind.work, Color(0xFF6C5CE7)),
    CalendarEntry(11, 'Walk & reset', '18:30 – 19:00', EntryKind.personal, Color(0xFF00B894)),
    CalendarEntry(12, 'Product review', '14:00 – 15:00', EntryKind.work, Color(0xFF0984E3)),
    CalendarEntry(14, "Children's Day", 'All day · India', EntryKind.holiday, Color(0xFFE17055)),
    CalendarEntry(17, 'Design critique', '11:30 – 12:15', EntryKind.work, Color(0xFF6C5CE7)),
    CalendarEntry(21, 'Asana: Draft launch plan', 'Due today', EntryKind.task, Color(0xFFFDCB6E)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(child: _header()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverToBoxAdapter(child: _viewSwitcher()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 360),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: Tween(begin: .97, end: 1.0).animate(animation), child: child),
                  ),
                  child: _view == CalendarView.month
                      ? _monthCard(key: const ValueKey('month'))
                      : _agenda(key: const ValueKey('agenda')),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
              sliver: SliverToBoxAdapter(child: _dayDetails()),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEvent,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New event'),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('TODAY', style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text('${_months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          ]),
        ),
        IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
        const SizedBox(width: 8),
        const CircleAvatar(child: Text('G')),
      ],
    );
  }

  Widget _viewSwitcher() {
    return SegmentedButton<CalendarView>(
      segments: const [
        ButtonSegment(value: CalendarView.month, icon: Icon(Icons.calendar_view_month_rounded), label: Text('Month')),
        ButtonSegment(value: CalendarView.agenda, icon: Icon(Icons.view_agenda_rounded), label: Text('Agenda')),
      ],
      selected: {_view},
      showSelectedIcon: false,
      onSelectionChanged: (value) => setState(() => _view = value.first),
    );
  }

  Widget _monthCard({Key? key}) {
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final days = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final leading = first.weekday - 1;
    return Card(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            IconButton(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left_rounded)),
            const Spacer(),
            Text('${_months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right_rounded)),
          ]),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _weekdays.map((day) => Center(child: Text(day,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700)))).toList(),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: leading + days,
            itemBuilder: (context, index) {
              if (index < leading) return const SizedBox.shrink();
              final day = index - leading + 1;
              final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
              return _dateCell(date);
            },
          ),
        ]),
      ),
    );
  }

  Widget _dateCell(DateTime date) {
    final selected = _sameDay(date, _selected);
    final hasEvent = _entries.any((entry) => entry.day == date.day);
    return Semantics(
      selected: selected,
      label: '${_months[date.month - 1]} ${date.day}',
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _selected = date),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${date.day}', style: TextStyle(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected ? Theme.of(context).colorScheme.onPrimary : null)),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: hasEvent ? 5 : 0,
              height: hasEvent ? 5 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.tertiary),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _agenda({Key? key}) {
    return Card(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: List.generate(7, (index) {
            final date = DateTime(_focusedMonth.year, _focusedMonth.month, 11 + index);
            final items = _entries.where((entry) => entry.day == date.day).toList();
            return InkWell(
              onTap: () => setState(() => _selected = date),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: 48, child: Column(children: [
                    Text(_weekdays[date.weekday - 1], style: Theme.of(context).textTheme.labelSmall),
                    Text('${date.day}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: items.isEmpty
                      ? Text('Open day', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
                      : Column(children: items.map(_compactEvent).toList())),
                ]),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _compactEvent(CalendarEntry entry) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: entry.color.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      Container(width: 4, height: 28, decoration: BoxDecoration(color: entry.color, borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(entry.time, style: Theme.of(context).textTheme.bodySmall),
      ])),
    ]),
  );

  Widget _dayDetails() {
    final items = _entries.where((entry) => entry.day == _selected.day).toList();
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('${_weekdays[_selected.weekday - 1]}, ${_months[_selected.month - 1].substring(0, 3).toUpperCase()} ${_selected.day}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const Spacer(),
          Text('${items.length} items', style: Theme.of(context).textTheme.bodySmall),
        ]),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Card(child: Padding(padding: const EdgeInsets.all(22), child: Row(children: [
            Icon(Icons.auto_awesome_rounded, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Expanded(child: Text('Nothing scheduled. A little breathing room.')),
          ])))
        else
          ...items.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _compactEvent(entry))),
        if (_selected.day == 14) ...[
          const SizedBox(height: 8),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.lightbulb_rounded),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('WHY THIS DATE MATTERS', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text("India celebrates Children's Day on 14 November, the birth anniversary of Jawaharlal Nehru."),
                ])),
              ]),
            ),
          ),
        ],
      ]),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
      _selected = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    });
  }

  void _showAddEvent() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Create an event', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          const TextField(autofocus: true, decoration: InputDecoration(labelText: 'Event name', prefixIcon: Icon(Icons.title_rounded), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.schedule_rounded), title: Text('${_months[_selected.month - 1]} ${_selected.day}'), subtitle: const Text('Choose time')),
          const SizedBox(height: 12),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Padding(padding: EdgeInsets.all(14), child: Text('Save event'))),
        ]),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

enum EntryKind { work, personal, holiday, task }

class CalendarEntry {
  const CalendarEntry(this.day, this.title, this.time, this.kind, this.color);
  final int day;
  final String title;
  final String time;
  final EntryKind kind;
  final Color color;
}
