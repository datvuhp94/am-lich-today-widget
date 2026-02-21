import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    preferredRepresentation: compactRepresentation

    property var lunarData: null
    property bool loading: true
    property bool hasError: false
    property string errorMsg: ""

    readonly property color redColor: "#DC143C"
    readonly property color goldColor: "#DAA520"
    readonly property color greenColor: "#22c55e"
    readonly property color blueColor: "#3b82f6"
    readonly property color yellowColor: "#f59e0b"
    readonly property color separatorColor: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)

    function formatHoangDao() {
        if (!lunarData || !lunarData.auspiciousHours) return "";
        var r = [];
        for (var i = 0; i < lunarData.auspiciousHours.length; i++) {
            if (lunarData.auspiciousHours[i].isHoangDao)
                r.push(lunarData.auspiciousHours[i].name);
        }
        return r.join(", ");
    }

    function formatAllHours() {
        if (!lunarData || !lunarData.auspiciousHours) return "";
        var lines = [];
        for (var i = 0; i < lunarData.auspiciousHours.length; i++) {
            var h = lunarData.auspiciousHours[i];
            lines.push((h.isHoangDao ? "● " : "○ ") + h.name);
        }
        return lines.join("\n");
    }

    function ratingColor() {
        if (!lunarData) return "transparent";
        if (lunarData.rating === "Đại Cát") return greenColor;
        if (lunarData.rating === "Cát") return blueColor;
        if (lunarData.rating === "Trung Bình") return yellowColor;
        return "#ef4444";
    }

    function ratingColorFor(r) {
        if (r === "Đại Cát") return greenColor;
        if (r === "Cát") return blueColor;
        return yellowColor;
    }

    function formatMonthYear() {
        if (!lunarData) return "";
        var s = "Tháng " + lunarData.lunar.month;
        if (lunarData.lunar.leap) s += " (nhuận)";
        s += " năm " + lunarData.canChi.year;
        return s;
    }

    function msUntilMidnight() {
        var n = new Date();
        var m = new Date(n.getFullYear(), n.getMonth(), n.getDate() + 1);
        return m.getTime() - n.getTime() + 5000;
    }

    function fetchData() {
        loading = true; hasError = false;
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try { lunarData = JSON.parse(xhr.responseText); loading = false; }
                    catch (e) { hasError = true; errorMsg = "Lỗi parse"; loading = false; }
                } else { hasError = true; errorMsg = "Lỗi " + xhr.status; loading = false; }
            }
        };
        xhr.open("GET", "https://amlich.today/api/widget");
        xhr.send();
    }

    Timer { interval: 1800000; running: true; repeat: true; onTriggered: fetchData() }
    Timer {
        id: mt
        running: true; repeat: false
        interval: root.msUntilMidnight()
        onTriggered: { fetchData(); mt.interval = 86400000; mt.repeat = true; }
    }
    Component.onCompleted: fetchData()

    // ============================================================
    // COMPACT: trên desktop
    // ============================================================
    compactRepresentation: MouseArea {
        Layout.minimumWidth: compactCol.implicitWidth + Kirigami.Units.smallSpacing * 2
        Layout.minimumHeight: compactCol.implicitHeight + Kirigami.Units.smallSpacing * 2
        Layout.preferredWidth: compactCol.implicitWidth + Kirigami.Units.largeSpacing * 2
        Layout.preferredHeight: compactCol.implicitHeight + Kirigami.Units.largeSpacing * 2
        onClicked: root.expanded = !root.expanded

        ColumnLayout {
            id: compactCol
            anchors.centerIn: parent
            spacing: 1

            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                text: lunarData ? lunarData.solar.dayOfWeek + " " + lunarData.solar.day + "/" + lunarData.solar.month + "/" + lunarData.solar.year : ""
                font.pixelSize: 13; opacity: 0.4
            }
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                text: lunarData ? lunarData.lunar.day : ""
                font.pixelSize: 52; font.bold: true; color: redColor
            }
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                text: formatMonthYear(); font.pixelSize: 13; opacity: 0.5
            }
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                text: lunarData ? lunarData.canChi.day : ""
                font.pixelSize: 14; font.bold: true
            }
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                text: lunarData ? lunarData.rating : ""
                font.pixelSize: 13; font.bold: true; color: ratingColor()
            }
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                visible: !!(lunarData && lunarData.holiday)
                text: lunarData && lunarData.holiday ? lunarData.holiday : ""
                font.pixelSize: 13; font.bold: true; color: redColor
            }

            Rectangle { Layout.preferredWidth: Kirigami.Units.gridUnit * 12; Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 4; height: 1; color: separatorColor }

            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 4
                text: "Giờ Hoàng Đạo"; font.pixelSize: 12; font.bold: true; color: goldColor
            }
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Kirigami.Units.gridUnit * 14
                text: formatHoangDao(); font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap
            }

            Rectangle { Layout.preferredWidth: Kirigami.Units.gridUnit * 12; Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 4; height: 1; color: separatorColor }

            PlasmaComponents.Label { Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 4; text: lunarData ? "Hỷ: " + lunarData.direction.hyThan : ""; font.pixelSize: 13; opacity: 0.6 }
            PlasmaComponents.Label { Layout.alignment: Qt.AlignHCenter; text: lunarData ? "Tài: " + lunarData.direction.taiThan : ""; font.pixelSize: 13; opacity: 0.6 }
            PlasmaComponents.Label { Layout.alignment: Qt.AlignHCenter; text: lunarData ? "Hạc: " + lunarData.direction.hacThan : ""; font.pixelSize: 13; opacity: 0.6 }

            Rectangle { Layout.preferredWidth: Kirigami.Units.gridUnit * 12; Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 4; height: 1; color: separatorColor }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 4
                spacing: Kirigami.Units.largeSpacing
                ColumnLayout {
                    spacing: 0
                    PlasmaComponents.Label { Layout.alignment: Qt.AlignHCenter; text: "Lục Diệu"; font.pixelSize: 11; opacity: 0.4 }
                    PlasmaComponents.Label { Layout.alignment: Qt.AlignHCenter; text: lunarData ? lunarData.lucDieu.name : ""; font.pixelSize: 13; font.bold: true }
                    PlasmaComponents.Label { Layout.alignment: Qt.AlignHCenter; text: lunarData && lunarData.lucDieu.rating ? lunarData.lucDieu.rating : ""; font.pixelSize: 11; color: lunarData && lunarData.lucDieu.rating === "Tốt" ? greenColor : (lunarData && lunarData.lucDieu.rating === "Xấu" ? redColor : yellowColor) }
                }
                Rectangle { Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5; width: 1; color: separatorColor }
                ColumnLayout {
                    spacing: 0
                    PlasmaComponents.Label { Layout.alignment: Qt.AlignHCenter; text: "Trực"; font.pixelSize: 11; opacity: 0.4 }
                    PlasmaComponents.Label { Layout.alignment: Qt.AlignHCenter; text: lunarData ? lunarData.kienTru.name : ""; font.pixelSize: 13; font.bold: true }
                }
                Rectangle { Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5; width: 1; color: separatorColor }
                ColumnLayout {
                    spacing: 0
                    PlasmaComponents.Label { Layout.alignment: Qt.AlignHCenter; text: "Sao"; font.pixelSize: 11; opacity: 0.4 }
                    PlasmaComponents.Label { Layout.alignment: Qt.AlignHCenter; text: lunarData ? lunarData.sao28.name : ""; font.pixelSize: 13; font.bold: true }
                    PlasmaComponents.Label { Layout.alignment: Qt.AlignHCenter; text: lunarData ? lunarData.sao28.attribute : ""; font.pixelSize: 11; color: lunarData && lunarData.sao28.attribute === "Cát" ? greenColor : redColor }
                }
            }

            Rectangle { Layout.preferredWidth: Kirigami.Units.gridUnit * 12; Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 6; height: 1; color: separatorColor }
            PlasmaComponents.Label { Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 4; text: "Ấn để xem chi tiết"; font.pixelSize: 11; opacity: 0.35; font.italic: true }
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 4
                text: "amlich.today"; font.pixelSize: 14; font.bold: true; color: "white"
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Qt.openUrlExternally("https://amlich.today") }
            }
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                text: "Âm Lịch • Ngày Tốt • Giờ Hoàng Đạo • Tử Vi • Phong Thủy"
                font.pixelSize: 10; color: "white"; opacity: 0.4
                Layout.preferredWidth: Kirigami.Units.gridUnit * 14
                horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap
            }
        }
    }

    // ============================================================
    // FULL: popup chi tiết — layout ngang rộng
    // ============================================================
    fullRepresentation: RowLayout {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 42
        Layout.minimumWidth: Kirigami.Units.gridUnit * 36
        spacing: 0

        // ── Cột 1: 12 giờ + Lục Diệu + Sao + Trực ──
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            Layout.margins: Kirigami.Units.smallSpacing
            spacing: 1

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: lunarData ? lunarData.solar.dayOfWeek + " " + lunarData.solar.day + "/" + lunarData.solar.month + "/" + lunarData.solar.year + "  —  " + lunarData.canChi.day + "  •  " + lunarData.rating : ""
                font.pixelSize: 11; font.bold: true; horizontalAlignment: Text.AlignHCenter; color: ratingColor()
            }
            Rectangle { Layout.fillWidth: true; height: 1; color: separatorColor }

            PlasmaComponents.Label { text: "Chi tiết 12 giờ"; font.pixelSize: 11; font.bold: true; color: goldColor; Layout.topMargin: 2 }
            PlasmaComponents.Label { Layout.fillWidth: true; text: formatAllHours(); font.pixelSize: 10; wrapMode: Text.Wrap; lineHeight: 1.3 }

            Rectangle { Layout.fillWidth: true; height: 1; color: separatorColor; Layout.topMargin: 3 }

            PlasmaComponents.Label { text: "Lục Diệu — " + (lunarData ? lunarData.lucDieu.name : ""); font.pixelSize: 11; font.bold: true; color: goldColor; Layout.topMargin: 3 }
            PlasmaComponents.Label { Layout.fillWidth: true; text: lunarData && lunarData.lucDieu.advice ? lunarData.lucDieu.advice : ""; font.pixelSize: 10; wrapMode: Text.Wrap; opacity: 0.8 }

            Rectangle { Layout.fillWidth: true; height: 1; color: separatorColor; Layout.topMargin: 3 }

            PlasmaComponents.Label { text: "Sao " + (lunarData ? lunarData.sao28.name : ""); font.pixelSize: 11; font.bold: true; color: goldColor; Layout.topMargin: 3 }
            PlasmaComponents.Label { Layout.fillWidth: true; visible: !!(lunarData && lunarData.sao28.description); text: lunarData ? (lunarData.sao28.description || "") : ""; font.pixelSize: 10; wrapMode: Text.Wrap; opacity: 0.8 }
            RowLayout { spacing: 4
                PlasmaComponents.Label { text: "Nên:"; font.pixelSize: 10; font.bold: true; color: greenColor }
                PlasmaComponents.Label { Layout.fillWidth: true; text: lunarData && lunarData.sao28.nenLam ? lunarData.sao28.nenLam : "—"; font.pixelSize: 10; wrapMode: Text.Wrap }
            }
            RowLayout { spacing: 4
                PlasmaComponents.Label { text: "Kỵ:"; font.pixelSize: 10; font.bold: true; color: redColor }
                PlasmaComponents.Label { Layout.fillWidth: true; text: lunarData && lunarData.sao28.kiengKy ? lunarData.sao28.kiengKy : "—"; font.pixelSize: 10; wrapMode: Text.Wrap }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: separatorColor; Layout.topMargin: 3 }

            PlasmaComponents.Label { text: "Trực " + (lunarData ? lunarData.kienTru.name : ""); font.pixelSize: 11; font.bold: true; color: goldColor; Layout.topMargin: 3 }
            RowLayout { spacing: 4
                PlasmaComponents.Label { text: "Nên:"; font.pixelSize: 10; font.bold: true; color: greenColor }
                PlasmaComponents.Label { Layout.fillWidth: true; text: lunarData && lunarData.kienTru.nenLam ? lunarData.kienTru.nenLam : "—"; font.pixelSize: 10; wrapMode: Text.Wrap }
            }
            RowLayout { spacing: 4
                PlasmaComponents.Label { text: "Kỵ:"; font.pixelSize: 10; font.bold: true; color: redColor }
                PlasmaComponents.Label { Layout.fillWidth: true; text: lunarData && lunarData.kienTru.khongNen ? lunarData.kienTru.khongNen : "—"; font.pixelSize: 10; wrapMode: Text.Wrap }
            }
        }

        // ── Đường chia ──
        Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: separatorColor }

        // ── Cột 2: Ngày đẹp ──
        ColumnLayout {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: Kirigami.Units.gridUnit * 14
            Layout.margins: Kirigami.Units.smallSpacing
            spacing: 2

            PlasmaComponents.Label {
                text: "Ngày Đẹp Tháng " + (lunarData ? lunarData.solar.month : "")
                font.pixelSize: 12; font.bold: true; color: goldColor
            }

            Repeater {
                model: lunarData && lunarData.ngayDepTrongThang ? lunarData.ngayDepTrongThang.length : 0
                delegate: RowLayout {
                    Layout.fillWidth: true; spacing: 6
                    required property int index
                    Rectangle {
                        width: 28; height: 28; radius: 4
                        color: lunarData.ngayDepTrongThang[index].day === lunarData.solar.day ? redColor : "transparent"
                        border.width: lunarData.ngayDepTrongThang[index].day === lunarData.solar.day ? 0 : 1
                        border.color: separatorColor
                        PlasmaComponents.Label {
                            anchors.centerIn: parent
                            text: lunarData.ngayDepTrongThang[index].day
                            font.pixelSize: 12; font.bold: true
                            color: lunarData.ngayDepTrongThang[index].day === lunarData.solar.day ? "white" : Kirigami.Theme.textColor
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 0
                        PlasmaComponents.Label { text: lunarData.ngayDepTrongThang[index].canChi; font.pixelSize: 10; font.bold: true }
                        RowLayout {
                            spacing: 4
                            PlasmaComponents.Label { text: "Â: " + lunarData.ngayDepTrongThang[index].lunar; font.pixelSize: 9; opacity: 0.5 }
                            PlasmaComponents.Label { text: lunarData.ngayDepTrongThang[index].rating; font.pixelSize: 9; font.bold: true; color: root.ratingColorFor(lunarData.ngayDepTrongThang[index].rating) }
                        }
                    }
                }
            }

            PlasmaComponents.Label {
                visible: !!(lunarData && lunarData.ngayDepTrongThang && lunarData.ngayDepTrongThang.length === 0)
                text: "Không có ngày đẹp"; font.pixelSize: 10; opacity: 0.5
            }

            Item { Layout.fillHeight: true }

            // Footer
            Rectangle { Layout.fillWidth: true; height: 1; color: separatorColor }
            PlasmaComponents.Label {
                Layout.fillWidth: true; Layout.topMargin: 4
                text: "amlich.today"; font.pixelSize: 14; font.bold: true
                color: "white"; horizontalAlignment: Text.AlignHCenter
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Qt.openUrlExternally("https://amlich.today") }
            }
            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: "Âm Lịch • Ngày Tốt • Giờ Hoàng Đạo • Tử Vi • Phong Thủy"
                font.pixelSize: 10; color: "white"; opacity: 0.4
                horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap
            }
        }
    }
}
