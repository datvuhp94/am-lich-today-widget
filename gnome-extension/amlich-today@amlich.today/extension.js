/* extension.js — Âm Lịch Today GNOME Shell Extension
 * GNOME 48 ESM module format
 * Hiển thị ngày âm trên top bar, click mở popup chi tiết
 */

import GLib from 'gi://GLib';
import Gio from 'gi://Gio';
import Clutter from 'gi://Clutter';
import St from 'gi://St';
import Soup from 'gi://Soup?version=3.0';
import GObject from 'gi://GObject';

import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';

const API_URL = 'https://amlich.today/api/widget';

// ── Indicator (nút trên top bar) ──────────────────────────
const AmLichIndicator = GObject.registerClass(
class AmLichIndicator extends PanelMenu.Button {
  _init(ext) {
    super._init(0.5, 'Âm Lịch Today');
    this._ext = ext;
    this._data = null;
    this._session = new Soup.Session();

    // ── Panel button label ──
    this._label = new St.Label({
      text: 'Âm Lịch...',
      y_align: Clutter.ActorAlign.CENTER,
      style_class: 'amlich-panel-label',
    });
    this.add_child(this._label);

    // ── Build popup ──
    this._buildPopup();

    // ── Fetch data ──
    this._fetchData();

    // ── Timers ──
    this._refreshTimer = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1800, () => {
      this._fetchData();
      return GLib.SOURCE_CONTINUE;
    });

    this._midnightTimer = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, this._secondsUntilMidnight(), () => {
      this._fetchData();
      // Set daily timer
      this._midnightTimer = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 86400, () => {
        this._fetchData();
        return GLib.SOURCE_CONTINUE;
      });
      return GLib.SOURCE_REMOVE;
    });
  }

  _secondsUntilMidnight() {
    const now = new Date();
    const midnight = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1);
    return Math.floor((midnight - now) / 1000) + 5;
  }

  // ── Build popup menu ──
  _buildPopup() {
    // Header
    this._headerItem = new PopupMenu.PopupMenuItem('', { reactive: false });
    this._headerItem.label.style_class = 'amlich-header';
    this.menu.addMenuItem(this._headerItem);

    this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

    // Main content area — custom widget
    const contentItem = new PopupMenu.PopupBaseMenuItem({ reactive: false, can_focus: false });
    this._contentBox = new St.BoxLayout({ vertical: false, style_class: 'amlich-content', x_expand: true });
    contentItem.add_child(this._contentBox);
    this.menu.addMenuItem(contentItem);

    // ── Left column: Info ──
    this._leftCol = new St.BoxLayout({ vertical: true, style_class: 'amlich-left-col', x_expand: true });
    this._contentBox.add_child(this._leftCol);

    // ── Separator ──
    const sep = new St.Widget({ style_class: 'amlich-vsep', y_expand: true });
    this._contentBox.add_child(sep);

    // ── Right column: Ngày đẹp ──
    this._rightCol = new St.BoxLayout({ vertical: true, style_class: 'amlich-right-col', x_expand: true });
    this._contentBox.add_child(this._rightCol);

    // Footer separator
    this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

    // Footer
    const footerItem = new PopupMenu.PopupMenuItem('', { reactive: true });
    footerItem.label.set_text('amlich.today — Âm Lịch • Ngày Tốt • Giờ Hoàng Đạo • Tử Vi • Phong Thủy');
    footerItem.label.style_class = 'amlich-footer';
    footerItem.connect('activate', () => {
      Gio.AppInfo.launch_default_for_uri('https://amlich.today', null);
    });
    this.menu.addMenuItem(footerItem);
  }

  // ── Fetch API data ──
  _fetchData() {
    const message = Soup.Message.new('GET', API_URL);
    this._session.send_and_read_async(message, GLib.PRIORITY_DEFAULT, null, (session, result) => {
      try {
        const bytes = session.send_and_read_finish(result);
        if (message.get_status() === Soup.Status.OK) {
          const text = new TextDecoder().decode(bytes.get_data());
          this._data = JSON.parse(text);
          this._updateUI();
        }
      } catch (e) {
        log(`[AmLich] Fetch error: ${e.message}`);
      }
    });
  }

  // ── Update all UI ──
  _updateUI() {
    const d = this._data;
    if (!d) return;

    // Panel label
    this._label.set_text(`${d.lunar.day}/${d.lunar.month} ${d.canChi.day}`);

    // Header
    this._headerItem.label.set_text(
      `${d.solar.dayOfWeek} ${d.solar.day}/${d.solar.month}/${d.solar.year}  —  Ngày ${d.lunar.day} Tháng ${d.lunar.month}${d.lunar.leap ? ' (nhuận)' : ''} năm ${d.canChi.year}`
    );

    // ── Left column ──
    this._leftCol.destroy_all_children();
    this._buildLeftCol();

    // ── Right column ──
    this._rightCol.destroy_all_children();
    this._buildRightCol();
  }

  _buildLeftCol() {
    const d = this._data;

    // Ngày âm to + Rating
    const dayBox = new St.BoxLayout({ vertical: true, style_class: 'amlich-day-box' });
    dayBox.add_child(new St.Label({ text: `${d.lunar.day}`, style_class: 'amlich-lunar-day' }));
    dayBox.add_child(new St.Label({ text: `Ngày ${d.canChi.day}`, style_class: 'amlich-canchi' }));
    dayBox.add_child(new St.Label({ text: `Tháng ${d.canChi.month}`, style_class: 'amlich-canchi-sub' }));
    dayBox.add_child(new St.Label({ text: d.rating, style_class: `amlich-rating amlich-rating-${this._ratingClass(d.rating)}` }));
    if (d.holiday) {
      dayBox.add_child(new St.Label({ text: d.holiday, style_class: 'amlich-holiday' }));
    }
    this._leftCol.add_child(dayBox);

    // Giờ Hoàng Đạo
    this._addSection(this._leftCol, 'Giờ Hoàng Đạo', this._formatHoangDao());

    // Hướng Xuất Hành
    this._addSection(this._leftCol, 'Hướng Xuất Hành',
      `Hỷ: ${d.direction.hyThan}\nTài: ${d.direction.taiThan}\nHạc: ${d.direction.hacThan}`);

    // Info tóm tắt
    const infoText = [
      `Lục Diệu: ${d.lucDieu.name} (${d.lucDieu.type || 'Bình'})`,
      `Trực: ${d.kienTru.name}`,
      `Sao: ${d.sao28.name} (${d.sao28.attribute})`,
    ];
    if (d.tietKhi) infoText.push(`Tiết Khí: ${d.tietKhi}`);
    this._addSection(this._leftCol, 'Thông Tin', infoText.join('\n'));

    // Chi tiết 12 giờ
    this._addSection(this._leftCol, 'Chi Tiết 12 Giờ', this._formatAllHours());

    // Lục Diệu
    if (d.lucDieu.meaning) {
      this._addSection(this._leftCol, `Lục Diệu — ${d.lucDieu.name}`, d.lucDieu.meaning);
    }

    // Sao 28
    let saoText = d.sao28.description || '';
    if (d.sao28.nenLam) saoText += `\n✓ Nên: ${d.sao28.nenLam}`;
    if (d.sao28.kiengKy) saoText += `\n✗ Kỵ: ${d.sao28.kiengKy}`;
    this._addSection(this._leftCol, `Sao ${d.sao28.name}`, saoText.trim());

    // Trực
    let trucText = d.kienTru.meaning || '';
    if (d.kienTru.nenLam) trucText += `\n✓ Nên: ${d.kienTru.nenLam}`;
    if (d.kienTru.khongNen) trucText += `\n✗ Kỵ: ${d.kienTru.khongNen}`;
    this._addSection(this._leftCol, `Trực ${d.kienTru.name}`, trucText.trim());
  }

  _buildRightCol() {
    const d = this._data;

    // Title
    this._rightCol.add_child(new St.Label({
      text: `Ngày Đẹp Tháng ${d.solar.month}`,
      style_class: 'amlich-section-title',
    }));

    const days = d.ngayDepTrongThang || [];
    if (days.length === 0) {
      this._rightCol.add_child(new St.Label({ text: 'Không có ngày đẹp', style_class: 'amlich-dim' }));
      return;
    }

    for (const day of days) {
      const row = new St.BoxLayout({ style_class: 'amlich-good-day-row', x_expand: true });

      // Day number badge
      const isToday = day.day === d.solar.day;
      const badge = new St.Label({
        text: `${day.day}`,
        style_class: isToday ? 'amlich-day-badge amlich-day-badge-today' : 'amlich-day-badge',
      });
      row.add_child(badge);

      // Info
      const info = new St.BoxLayout({ vertical: true, x_expand: true });
      info.add_child(new St.Label({ text: day.canChi, style_class: 'amlich-good-day-canchi' }));

      const sub = new St.BoxLayout({});
      sub.add_child(new St.Label({ text: `Â: ${day.lunar}`, style_class: 'amlich-dim' }));
      sub.add_child(new St.Label({ text: `  ${day.rating}`, style_class: `amlich-rating-small amlich-rating-${this._ratingClass(day.rating)}` }));
      info.add_child(sub);

      row.add_child(info);
      this._rightCol.add_child(row);
    }
  }

  _addSection(parent, title, content) {
    const sep = new St.Widget({ style_class: 'amlich-hsep' });
    parent.add_child(sep);

    parent.add_child(new St.Label({ text: title, style_class: 'amlich-section-title' }));
    if (content) {
      parent.add_child(new St.Label({
        text: content,
        style_class: 'amlich-section-content',
        x_expand: true,
      }));
    }
  }

  _formatHoangDao() {
    if (!this._data || !this._data.auspiciousHours) return '';
    return this._data.auspiciousHours
      .filter(h => h.isHoangDao)
      .map(h => h.name)
      .join(', ');
  }

  _formatAllHours() {
    if (!this._data || !this._data.auspiciousHours) return '';
    return this._data.auspiciousHours
      .map(h => `${h.isHoangDao ? '●' : '○'} ${h.name}`)
      .join('\n');
  }

  _ratingClass(rating) {
    if (rating === 'Đại Cát') return 'great';
    if (rating === 'Cát') return 'good';
    if (rating === 'Trung Bình') return 'average';
    return 'bad';
  }

  destroy() {
    if (this._refreshTimer) {
      GLib.source_remove(this._refreshTimer);
      this._refreshTimer = null;
    }
    if (this._midnightTimer) {
      GLib.source_remove(this._midnightTimer);
      this._midnightTimer = null;
    }
    this._session = null;
    super.destroy();
  }
});

// ── Extension entry point ─────────────────────────────────
export default class AmLichExtension extends Extension {
  enable() {
    this._indicator = new AmLichIndicator(this);
    Main.panel.addToStatusArea('amlich-today', this._indicator);
  }

  disable() {
    if (this._indicator) {
      this._indicator.destroy();
      this._indicator = null;
    }
  }
}
