const fs = require("fs");
const path = require("path");

const outputDirectory = process.argv[2];
const theme = process.argv[3] || "dark";
const brightVersion = 2;
if (!outputDirectory) {
  throw new Error("Usage: node generate_all_mockups.js OUTPUT_DIRECTORY [dark|bright]");
}
fs.mkdirSync(outputDirectory, { recursive: true });

const darkColor = {
  bg0: "#07111F",
  bg1: "#0D1B2C",
  panel: "#13253A",
  panelHi: "#1C3550",
  outline: "#02060C",
  text: "#F4E9D5",
  muted: "#91A2B5",
  cyan: "#47D7E8",
  cyanDark: "#2697AA",
  coral: "#FF657A",
  green: "#65D59A",
  amber: "#F1B45B",
  overlay: "#07111FCC",
  overlaySoft: "#07111F55",
  onDark: "#F4E9D5",
  onDarkMuted: "#91A2B5",
};

const brightColor = {
  bg0: "#F7FCFF",
  bg1: "#E8F7FF",
  panel: "#FFFFFF",
  panelHi: "#DDF6FF",
  outline: "#14324A",
  text: "#10283B",
  muted: "#557286",
  cyan: "#00B8D9",
  cyanDark: "#007F9E",
  coral: "#FF5573",
  green: "#28C98B",
  amber: "#FFB229",
  overlay: "#14324AD9",
  overlaySoft: "#14324A30",
  onDark: "#FFFFFF",
  onDarkMuted: "#C7E7F1",
};

const isBright = theme === "bright";
const color = isBright ? brightColor : darkColor;

const esc = (value) => String(value)
  .replaceAll("&", "&amp;")
  .replaceAll("<", "&lt;")
  .replaceAll(">", "&gt;");

const rect = (x, y, width, height, fill, stroke = "", strokeWidth = 1) =>
  `<rect x="${x}" y="${y}" width="${width}" height="${height}" fill="${fill}"${stroke ? ` stroke="${stroke}" stroke-width="${strokeWidth}"` : ""}/>`;
const line = (x1, y1, x2, y2, stroke, strokeWidth = 1) =>
  `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${stroke}" stroke-width="${strokeWidth}"/>`;
const text = (x, y, value, size = 8, fill = color.text, weight = 600, anchor = "start") =>
  `<text x="${x}" y="${y}" fill="${fill}" font-size="${size}" font-weight="${weight}" text-anchor="${anchor}">${esc(value)}</text>`;
const panel = (x, y, width, height, selected = false) =>
  rect(x, y, width, height, color.panel, selected ? color.cyan : color.outline, 1);
const button = (x, y, width, height, label, selected = false, danger = false) => {
  const border = danger ? color.coral : selected ? color.cyan : color.outline;
  const fill = selected ? color.panelHi : color.panel;
  const labelColor = danger ? color.coral : selected ? color.text : color.muted;
  return `${rect(x, y, width, height, fill, border)}${text(x + 8, y + height - 5, label, 8, labelColor, 700)}`;
};
const progress = (x, y, width, value, fill = color.cyan) =>
  `${rect(x, y, width, 4, color.outline)}${rect(x + 1, y + 1, Math.max(1, Math.round((width - 2) * value)), 2, fill)}`;
const cursor = (x, y, fill = color.cyan) =>
  `<path d="M${x} ${y} L${x + 5} ${y + 3} L${x} ${y + 6} Z" fill="${fill}"/>`;
const badge = (x, y, label, fill = color.cyan) =>
  `${rect(x, y, label.length * 5 + 8, 12, color.bg1, fill)}${text(x + 4, y + 9, label, 6, fill, 700)}`;
const silhouette = (x, y, width = 28, height = 34, fill = color.muted) =>
  `${rect(x + width / 2 - 5, y + 3, 10, 10, fill)}${rect(x + width / 2 - 8, y + 13, 16, height - 16, fill)}${rect(x + width / 2 - 11, y + height - 7, 22, 7, fill)}`;
const tuto = (x, y, error = false) =>
  `${rect(x + 4, y, 14, 20, color.text)}${rect(x, y + 5, 22, 10, color.text)}${rect(x + 6, y + 5, 10, 8, color.panel)}${rect(x + 8, y + 7, 2, 3, color.cyan)}${rect(x + 13, y + 7, 2, 3, error ? color.coral : color.cyan)}${rect(x + 1, y + 8, 2, 4, color.cyan)}${rect(x + 19, y + 8, 2, 4, error ? color.coral : color.cyan)}${rect(x + 6, y + 20, 3, 3, color.outline)}${rect(x + 14, y + 20, 3, 3, color.outline)}`;
const player = (x, y) =>
  `<svg x="${x}" y="${y}" width="32" height="48" viewBox="0 0 32 48" overflow="hidden"><image href="../../game/assets/characters/iwol_walk_32x48_v1.png" x="0" y="0" width="96" height="192" style="image-rendering:pixelated"/></svg>`;
const portrait = (x, y) =>
  `${panel(x, y, 28, 28)}${rect(x + 8, y + 4, 12, 8, "#27645D")}${rect(x + 6, y + 10, 16, 9, "#F0B79E")}${rect(x + 5, y + 4, 18, 4, color.coral)}${rect(x + 9, y + 13, 2, 2, color.outline)}${rect(x + 17, y + 13, 2, 2, color.outline)}${rect(x + 8, y + 19, 12, 7, color.text)}`;
const footer = (left = "선택", right = "뒤로") =>
  `${line(12, 162, 308, 162, color.panelHi)}${text(14, 174, `Z  ${left}`, 6, color.muted, 600)}${text(306, 174, `X  ${right}`, 6, color.muted, 600, "end")}`;
const header = (title, subtitle = "") =>
  `${text(12, 18, title, 12, color.text, 800)}${subtitle ? text(12, 29, subtitle, 6, color.muted, 600) : ""}${line(12, 34, 308, 34, color.panelHi)}`;
const svg = (content) => `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="1280" height="720" viewBox="0 0 320 180" shape-rendering="crispEdges">
  <style>text{font-family:NanumGothic,Apple SD Gothic Neo,sans-serif}</style>
  ${rect(0, 0, 320, 180, color.bg0)}
  ${content}
</svg>\n`;

const room = () => `${rect(126, 16, 182, 132, color.bg1)}${rect(134, 24, 72, 50, color.panel)}${rect(142, 34, 40, 24, color.outline)}${rect(144, 36, 36, 20, color.panelHi)}${rect(156, 43, 12, 6, color.cyan)}${rect(144, 62, 58, 4, color.outline)}${rect(150, 68, 4, 18, color.outline)}${rect(192, 68, 4, 18, color.outline)}${rect(132, 94, 78, 42, color.panel)}${rect(138, 100, 66, 4, color.panelHi)}`;
const portal = (x = 246, y = 28, error = true) => `${rect(x, y, 54, 108, color.outline)}${rect(x + 2, y + 2, 50, 104, color.panel)}${rect(x + 6, y + 6, 42, 96, color.bg0)}${rect(x + 2, y + 12, 4, 18, color.cyan)}${rect(x + 48, y + 20, 4, 24, error ? color.coral : color.cyan)}${rect(x + 2, y + 64, 4, 26, error ? color.coral : color.cyan)}${rect(x + 48, y + 58, 4, 20, color.cyan)}${rect(x + 16, y + 42, 5, 5, color.cyan)}${rect(x + 30, y + 68, 4, 4, error ? color.coral : color.cyan)}`;
const chat = (x = 252, y = 40) => `${panel(x, y, 56, 100)}${text(x + 6, y + 12, "가상 채팅", 6, color.text, 700)}${line(x + 4, y + 17, x + 52, y + 17, color.panelHi)}${rect(x + 6, y + 24, 5, 5, color.cyan)}${rect(x + 14, y + 24, 31, 3, color.muted)}${rect(x + 14, y + 30, 24, 3, color.panelHi)}${rect(x + 6, y + 42, 5, 5, color.coral)}${rect(x + 14, y + 42, 34, 3, color.muted)}${rect(x + 14, y + 48, 19, 3, color.panelHi)}${rect(x + 6, y + 60, 5, 5, color.green)}${rect(x + 14, y + 60, 28, 3, color.muted)}${rect(x + 14, y + 66, 32, 3, color.panelHi)}`;

function saveLoad() {
  let content = header("저장 · 불러오기", "선택한 기록의 상세 정보를 확인합니다.");
  content += panel(12, 42, 196, 110);
  const rows = [
    [48, "01", "1장 접속 광장", "00:42:18", true],
    [82, "02", "프롤로그", "00:12:04", false],
    [116, "03", "빈 슬롯", "--:--:--", false],
  ];
  for (const [y, number, name, time, selected] of rows) {
    content += panel(18, y, 184, 28, selected);
    content += selected ? cursor(14, y + 11) : "";
    content += text(24, y + 18, number, 9, selected ? color.cyan : color.muted, 800);
    content += rect(45, y + 5, 32, 18, selected ? color.panelHi : color.bg1, color.outline);
    content += text(84, y + 13, name, 8, selected ? color.text : color.muted, 700);
    content += text(196, y + 20, time, 6, color.muted, 600, "end");
  }
  content += panel(216, 42, 92, 110, true);
  content += text(224, 55, "선택 기록", 8, color.text, 700);
  content += portrait(224, 62);
  content += text(258, 72, "이월짱", 7, color.text, 700);
  content += text(258, 82, "1장 접속 광장", 6, color.muted, 600);
  content += line(224, 96, 300, 96, color.panelHi);
  content += text(224, 108, "동행자", 6, color.muted, 600);
  content += text(300, 108, "서윤", 7, color.text, 700, "end");
  content += text(224, 120, "튜토 단서", 6, color.muted, 600);
  content += text(300, 120, "2 / 8", 7, color.cyan, 700, "end");
  content += badge(224, 132, "자동 저장", color.coral);
  return svg(content + footer("불러오기", "뒤로") + text(124, 174, "Y  삭제", 6, color.coral, 700));
}

function settings() {
  let content = header("설정", "항목별로 언제든 다시 변경할 수 있습니다.");
  content += panel(12, 42, 78, 110);
  const categories = ["화면", "소리", "접근성", "조작"];
  categories.forEach((label, index) => {
    const y = 50 + index * 24;
    content += button(18, y, 66, 18, label, index === 2);
    if (index === 2) content += cursor(14, y + 6);
  });
  content += panel(98, 42, 210, 110, true);
  content += text(106, 56, "접근성", 9, color.text, 800);
  const options = [
    [70, "화면 흔들림", "약하게", true],
    [87, "번쩍임", "줄이기", true],
    [104, "큰 소리", "경고", true],
    [121, "공포 연출", "약하게", false],
    [138, "가짜 종료 화면", "끄기", false],
  ];
  for (const [y, label, value, selected] of options) {
    content += line(106, y + 7, 300, y + 7, color.panelHi);
    content += text(108, y, label, 7, selected ? color.text : color.muted, 600);
    content += text(294, y, value, 7, selected ? color.cyan : color.muted, 700, "end");
    content += rect(298, y - 8, 4, 8, selected ? color.cyan : color.panelHi);
  }
  return svg(content + footer("변경", "적용하고 뒤로"));
}

function pause() {
  let content = room() + player(178, 100) + tuto(220, 106) + rect(0, 0, 320, 180, color.overlay);
  content += panel(92, 22, 136, 136, true);
  content += text(160, 42, "일시정지", 12, color.text, 800, "middle");
  const labels = ["계속하기", "저장하기", "설정", "타이틀로", "게임 종료"];
  labels.forEach((label, index) => {
    const y = 52 + index * 19;
    content += button(108, y, 104, 15, label, index === 0, index === 4);
  });
  content += text(160, 151, "현재 진행은 자동 저장되지 않습니다.", 6, color.muted, 600, "middle");
  return svg(content);
}

function chapterCard() {
  return svg(`${rect(0, 0, 320, 180, color.bg1)}${rect(12, 12, 296, 156, color.panel)}${line(44, 73, 276, 73, color.cyan, 2)}${text(160, 54, "1장", 10, color.cyan, 800, "middle")}${text(160, 95, "접속 광장의 두 얼굴", 16, color.text, 800, "middle")}${text(160, 117, "첫인상은 기록되고, 선택은 되돌릴 수 없습니다.", 7, color.muted, 600, "middle")}${text(160, 151, "아무 버튼이나 눌러 계속", 6, color.muted, 600, "middle")}`);
}

function resultCredits() {
  let content = header("플레이 결과", "이번 방송에서 남긴 선택을 확인합니다.");
  content += panel(12, 42, 144, 110, true) + panel(164, 42, 144, 110);
  content += text(20, 58, "선택 기록", 9, color.text, 800);
  content += text(20, 76, "동행자", 6, color.muted) + text(146, 76, "서윤", 7, color.text, 700, "end");
  content += text(20, 92, "후보 포기", 6, color.muted) + text(146, 92, "0명", 7, color.text, 700, "end");
  content += text(20, 108, "튜토 단서", 6, color.muted) + text(146, 108, "2 / 8", 7, color.cyan, 700, "end");
  content += text(20, 124, "플레이 시간", 6, color.muted) + text(146, 124, "00:42:18", 7, color.text, 700, "end");
  content += text(172, 58, "제작 및 권리", 9, color.text, 800);
  content += text(172, 76, "기획 · 개발", 6, color.muted) + text(300, 76, "IwolNoLogout", 6, color.text, 700, "end");
  content += text(172, 92, "팬메이드", 6, color.muted) + text(300, 92, "비공식 프로젝트", 6, color.text, 700, "end");
  content += text(172, 112, "사용 자산과 허가 정보는", 6, color.muted);
  content += text(172, 121, "전체 크레딧에서 확인합니다.", 6, color.muted);
  return svg(content + footer("전체 크레딧", "타이틀로"));
}

function exploration() {
  let content = room() + player(174, 94) + tuto(216, 104) + chat();
  content += panel(8, 8, 92, 28) + portrait(12, 8) + text(44, 18, "이월짱", 7, color.text, 700);
  content += progress(44, 23, 48, 0.72, color.coral) + progress(44, 29, 48, 0.9, color.cyan);
  content += panel(8, 140, 92, 30) + badge(14, 149, "쿠나이", color.cyan) + text(64, 157, "준비", 7, color.text, 700);
  content += text(160, 174, "E  상호작용", 6, color.muted, 600, "middle");
  return svg(content);
}

function dialogue() {
  let content = room() + player(176, 96) + tuto(222, 106);
  content += rect(0, 0, 320, 180, color.overlaySoft);
  content += panel(10, 112, 300, 58, true) + portrait(18, 121);
  content += text(52, 126, "이월짱", 8, color.cyan, 800);
  content += text(52, 141, "종료 버튼을 눌렀는데… 왜 방송이 계속되지?", 8, color.text, 600);
  content += text(52, 155, "튜토, 이거 정말 복구 절차 맞아?", 8, color.text, 600);
  content += text(300, 164, "▼", 7, color.cyan, 700, "end");
  return svg(content);
}

function tutorial() {
  let content = room() + player(176, 96) + tuto(224, 104);
  content += panel(64, 40, 192, 96, true);
  content += text(160, 58, "이동하기", 11, color.text, 800, "middle");
  content += rect(132, 72, 18, 18, color.panelHi, color.outline) + text(141, 85, "W", 8, color.text, 800, "middle");
  content += rect(112, 92, 18, 18, color.panelHi, color.outline) + text(121, 105, "A", 8, color.text, 800, "middle");
  content += rect(132, 92, 18, 18, color.panelHi, color.outline) + text(141, 105, "S", 8, color.text, 800, "middle");
  content += rect(152, 92, 18, 18, color.panelHi, color.outline) + text(161, 105, "D", 8, color.text, 800, "middle");
  content += text(188, 85, "방향키도 사용할 수 있습니다.", 6, color.muted, 600);
  content += text(188, 102, "이동 중에는 마지막 방향을", 6, color.muted, 600);
  content += text(188, 111, "기억합니다.", 6, color.muted, 600);
  content += button(120, 118, 80, 14, "확인", true);
  return svg(content);
}

function combat() {
  let content = rect(8, 38, 304, 108, color.bg1) + rect(18, 48, 284, 88, color.panel);
  content += player(58, 78) + silhouette(224, 74, 34, 44, color.coral) + silhouette(140, 88, 24, 32, color.green);
  content += line(92, 102, 220, 82, color.cyan, 2) + rect(150, 91, 5, 5, color.cyan);
  content += text(34, 42, "이월짱", 6, color.text, 700) + progress(34, 46, 62, 0.8, color.coral);
  content += text(206, 42, "노이즈 적", 6, color.text, 700) + progress(206, 46, 74, 0.45, color.coral);
  content += text(126, 132, "+18 회복", 7, color.green, 800);
  content += panel(10, 8, 126, 24) + text(18, 18, "쿠나이", 7, color.cyan, 700) + text(18, 27, "적: 피해  ·  동행자: 회복", 6, color.muted);
  content += panel(10, 150, 92, 22) + badge(16, 155, "투척", color.cyan) + text(66, 164, "0.4초", 6, color.text, 700);
  return svg(content + chat(252, 48));
}

function companionStatus() {
  let content = header("동행자", "확정한 동행자는 마지막까지 함께합니다.");
  content += panel(12, 42, 90, 110, true) + silhouette(40, 56, 34, 42, color.muted);
  content += text(57, 112, "서윤", 10, color.text, 800, "middle") + badge(32, 122, "고정 동행", color.cyan);
  content += panel(110, 42, 198, 110);
  content += text(120, 57, "방송 매니저", 8, color.text, 700);
  content += text(120, 72, "신뢰", 6, color.muted) + progress(164, 68, 126, 0.64, color.cyan);
  content += text(120, 88, "상태", 6, color.muted) + text(290, 88, "안정", 7, color.green, 700, "end");
  content += line(120, 98, 298, 98, color.panelHi);
  content += text(120, 112, "고유 반응", 6, color.muted, 700);
  content += text(120, 124, "선택 기록을 정리해 위험한 결정을", 6, color.text);
  content += text(120, 134, "한 번 더 확인하도록 돕습니다.", 6, color.text);
  return svg(content + footer("관계 기록", "뒤로"));
}

function logs() {
  let content = header("로그 · 단서", "관리자 기록과 튜토의 행동을 비교합니다.");
  content += panel(12, 42, 82, 110);
  ["프롤로그", "1장", "2장", "3장", "4장", "최종장"].forEach((label, index) => {
    const y = 50 + index * 16;
    content += text(22, y + 9, label, 7, index === 1 ? color.text : color.muted, index === 1 ? 700 : 600);
    if (index === 1) content += rect(16, y + 3, 3, 8, color.cyan);
  });
  content += panel(102, 42, 206, 110, true);
  content += text(112, 56, "관리자 로그 01-03", 8, color.text, 800) + badge(246, 48, "부분 손상", color.coral);
  content += text(112, 73, "권한: 문 열기 / 문 잠금", 7, color.text);
  content += text(112, 88, "종료 요청 수신: 1회", 7, color.text);
  content += text(112, 103, "종료 처리 결과:", 7, color.text) + rect(206, 95, 76, 10, color.outline);
  content += text(112, 121, "복구 담당: TUTO", 7, color.text);
  content += text(112, 138, "단서 2 / 8", 7, color.cyan, 700);
  return svg(content + footer("상세 보기", "뒤로"));
}

function downed() {
  return svg(`${rect(0, 0, 320, 180, color.outline)}${text(160, 54, "연결이 끊어졌습니다", 14, color.coral, 800, "middle")}${text(160, 74, "마지막 체크포인트에서 다시 시작할 수 있습니다.", 7, color.onDarkMuted, 600, "middle")}${button(96, 92, 128, 18, "체크포인트 재개", true)}${button(96, 116, 128, 18, "타이틀로", false)}${text(160, 154, "저장 데이터는 손상되지 않았습니다.", 6, color.onDarkMuted, 600, "middle")}`);
}

function clipResult() {
  let content = room() + player(172, 98) + chat();
  content += panel(30, 14, 212, 34, true) + text(42, 29, "클립 구간", 7, color.cyan, 800) + text(232, 31, "미션 성공", 11, color.text, 800, "end");
  content += panel(34, 116, 204, 42) + text(44, 130, "채팅 반응", 6, color.muted, 700);
  content += text(44, 146, "안정적인 진행", 8, color.text, 700) + text(228, 146, "+124", 8, color.green, 800, "end");
  return svg(content + text(136, 174, "A  계속", 6, color.muted, 600, "middle"));
}

function streamEnd() {
  let content = room() + player(174, 98) + chat();
  content += panel(14, 18, 104, 92) + text(22, 32, "방송 제어", 8, color.text, 800);
  content += text(22, 50, "방송 시간", 6, color.muted) + text(108, 50, "02:14:08", 7, color.text, 700, "end");
  content += text(22, 66, "현재 상태", 6, color.muted) + text(108, 66, "송출 중", 7, color.green, 700, "end");
  content += button(22, 82, 88, 18, "방송 종료", true, true);
  content += text(160, 164, "오늘 방송도 고생하셨습니다.", 7, color.muted, 600, "middle");
  return svg(content);
}

function logoutFailure() {
  let content = room() + player(174, 98) + chat() + rect(0, 0, 320, 180, color.overlaySoft);
  content += panel(70, 48, 180, 84, true) + rect(70, 48, 180, 4, color.coral);
  content += text(160, 70, "로그아웃 실패", 12, color.coral, 800, "middle");
  content += text(160, 88, "종료 권한을 확인할 수 없습니다.", 7, color.text, 600, "middle");
  content += text(160, 102, "복구 절차를 시작하시겠습니까?", 7, color.muted, 600, "middle");
  content += button(92, 112, 60, 14, "취소", false) + button(168, 112, 60, 14, "복구", true);
  return svg(content);
}

function tutoIntro() {
  let content = room() + player(154, 102) + tuto(214, 82);
  content += panel(48, 126, 224, 40, true) + text(58, 139, "튜토", 7, color.cyan, 800);
  content += text(58, 153, "안녕하세요. 안전한 로그아웃을 위한 복구 절차를 안내할게요.", 7, color.text, 600);
  content += rect(236, 90, 3, 3, color.coral);
  return svg(content);
}

function adminLog() {
  let content = rect(18, 14, 284, 152, color.panel, color.cyan) + text(30, 32, "ADMIN LOG / 00", 9, color.cyan, 800);
  content += line(30, 40, 290, 40, color.panelHi);
  const rows = [
    [54, "SESSION", "IWOL_LIVE_021"],
    [70, "EXIT_REQUEST", "RECEIVED"],
    [86, "EXIT_PERMISSION", "DENIED"],
    [102, "RECOVERY_AGENT", "TUTO"],
    [118, "KEEP_ALIVE", "ACTIVE"],
  ];
  for (const [y, key, value] of rows) {
    content += text(32, y, key, 6, color.muted, 700) + text(144, y, value, 7, value === "DENIED" || value === "ACTIVE" ? color.coral : color.text, 700);
  }
  content += rect(144, 128, 124, 10, color.outline) + text(32, 136, "OWNER", 6, color.muted, 700);
  content += text(160, 156, "일부 기록이 손상되었습니다.", 6, color.muted, 600, "middle");
  return svg(content);
}

function prologueHero() {
  let content = room() + portal(194, 28, true) + player(150, 94) + tuto(220, 106, true) + chat();
  content += panel(8, 8, 102, 30) + text(16, 20, "프롤로그", 6, color.cyan, 700) + text(16, 31, "접속 종료 실패", 10, color.text, 800);
  content += panel(10, 142, 154, 28) + text(18, 154, "목표", 6, color.muted, 700) + text(50, 154, "종료 단서를 찾기", 7, color.text, 700);
  content += text(18, 165, "튜토의 안내를 따라 이동하세요.", 6, color.muted);
  return svg(content);
}

const candidateCard = (x, label, title, role, constraint, selected = false) => `${panel(x, 48, 132, 94, selected)}${text(x + 10, 64, label, 12, selected ? color.cyan : color.muted, 800)}${silhouette(x + 50, 65, 32, 38, color.muted)}${text(x + 66, 116, title, 8, color.text, 800, "middle")}${text(x + 66, 128, role, 6, color.muted, 600, "middle")}${text(x + 66, 138, constraint, 6, color.amber, 600, "middle")}`;

function limitedAB() {
  let content = header("후보 1라운드", "제한 정보만 보고 첫인상을 남깁니다.");
  content += candidateCard(20, "A", "안정형", "방송 관리", "공격 템포 감소", true);
  content += candidateCard(168, "B", "즉흥형", "현장 진행", "위험 판단 지연", false);
  content += text(160, 156, "전체 프로필은 판정 후 동시에 공개됩니다.", 6, color.muted, 600, "middle");
  return svg(content + footer("첫인상 판정", "나중에"));
}

function firstImpression() {
  let content = header("첫인상 판정", "정답은 없으며 작은 신뢰 보정에만 반영됩니다.");
  content += candidateCard(20, "A", "안정형", "방송 관리", "공격 템포 감소", true);
  content += candidateCard(168, "B", "즉흥형", "현장 진행", "위험 판단 지연", false);
  content += button(54, 148, 58, 16, "A 선택", true) + button(131, 148, 58, 16, "보류", false) + button(208, 148, 58, 16, "B 선택", false);
  return svg(content);
}

function fullReveal() {
  let content = header("두 후보 공개", "두 사람을 확인한 뒤 한 명을 확정하거나 모두 포기합니다.");
  content += panel(12, 42, 144, 110, true) + panel(164, 42, 144, 110);
  content += text(24, 58, "A  서윤", 10, color.cyan, 800) + silhouette(24, 66, 30, 38, color.muted);
  content += text(64, 75, "방송 매니저", 7, color.text, 700) + text(64, 88, "일정과 선택 기록", 6, color.muted);
  content += text(24, 116, "강점  구조와 안정", 6, color.green, 700) + text(24, 130, "제약  공격 템포 감소", 6, color.amber, 700);
  content += text(176, 58, "B  도윤", 10, color.coral, 800) + silhouette(176, 66, 30, 38, color.muted);
  content += text(216, 75, "현장 진행자", 7, color.text, 700) + text(216, 88, "즉흥 해결과 분위기", 6, color.muted);
  content += text(176, 116, "강점  돌발 상황 전환", 6, color.green, 700) + text(176, 130, "제약  위험 판단 지연", 6, color.amber, 700);
  return svg(content + footer("동행 선택", "모두 포기"));
}

function companionConfirm() {
  let content = header("동행자 확정", "이 선택은 이번 회차에서 되돌릴 수 없습니다.");
  content += panel(58, 46, 204, 92, true) + silhouette(76, 62, 34, 42, color.muted);
  content += text(124, 70, "서윤", 12, color.text, 800) + text(124, 86, "안정형 방송 매니저", 7, color.muted, 600);
  content += text(124, 104, "확정하면 이후 후보 라운드는 종료됩니다.", 6, color.amber, 700);
  content += button(80, 116, 72, 16, "다시 보기", false) + button(168, 116, 72, 16, "확정", true);
  return svg(content);
}

function abandonBoth() {
  let content = header("두 후보 모두 포기", "포기한 후보는 이번 회차에서 다시 만날 수 없습니다.");
  content += candidateCard(20, "A", "서윤", "방송 매니저", "영구 포기", false);
  content += candidateCard(168, "B", "도윤", "현장 진행자", "영구 포기", false);
  content += line(30, 58, 142, 132, color.coral, 3) + line(178, 58, 290, 132, color.coral, 3);
  content += button(84, 148, 64, 16, "취소", false) + button(172, 148, 64, 16, "포기 확정", false, true);
  return svg(content);
}

function nextRound() {
  let content = header("다음 라운드", "이전 선택으로 돌아갈 수 없습니다.");
  content += text(160, 62, "1 / 8 라운드 종료", 12, color.text, 800, "middle");
  content += progress(56, 76, 208, 0.125, color.cyan);
  content += panel(62, 92, 196, 38) + text(72, 108, "서윤 · 도윤", 7, color.muted, 700) + badge(194, 98, "영구 포기", color.coral);
  content += button(104, 140, 112, 18, "2라운드로", true);
  return svg(content);
}

function fixedCompanion() {
  let content = header("동행자 확정 완료", "이후 후보 선택 화면은 열리지 않습니다.");
  content += panel(54, 46, 212, 96, true) + silhouette(72, 64, 40, 48, color.muted);
  content += text(132, 70, "서윤", 13, color.text, 800) + badge(132, 80, "고정 동행", color.cyan);
  content += text(132, 105, "선택 기록과 위험 경고를 지원합니다.", 7, color.muted, 600);
  content += text(132, 120, "모든 챕터와 엔딩을 함께합니다.", 7, color.text, 600);
  return svg(content + footer("모험 계속", "상세 보기"));
}

const mapBase = (accent = color.cyan) => `${rect(0, 0, 320, 180, color.bg0)}${rect(12, 24, 236, 142, color.bg1)}${rect(22, 34, 216, 122, color.panel)}${rect(32, 44, 42, 28, color.panelHi)}${rect(176, 42, 48, 30, color.panelHi)}${rect(38, 118, 52, 26, color.panelHi)}${rect(158, 116, 62, 28, color.panelHi)}${line(24, 90, 232, 90, accent)}${line(128, 36, 128, 154, accent)}`;

function squareScene() {
  let content = mapBase(color.cyan) + player(112, 78) + tuto(150, 94) + chat();
  content += badge(18, 10, "1장 접속 광장", color.cyan) + panel(8, 148, 116, 24) + text(16, 159, "목표", 6, color.muted, 700) + text(46, 159, "광장 중앙으로 이동", 6, color.text, 700);
  return svg(content);
}

function bossScene() {
  let content = mapBase(color.coral) + player(48, 94) + silhouette(162, 60, 58, 68, color.coral);
  content += rect(148, 50, 76, 6, color.outline) + progress(150, 52, 72, 0.68, color.coral);
  content += text(186, 46, "노이즈 모더레이터", 7, color.text, 800, "middle");
  content += line(82, 104, 160, 84, color.cyan, 2) + rect(118, 92, 5, 5, color.cyan);
  content += panel(8, 8, 98, 24) + text(16, 18, "쿠나이", 6, color.cyan, 700) + text(16, 27, "공격 / 회복 전환", 6, color.muted);
  return svg(content + chat());
}

function healingStudio() {
  let content = mapBase(color.green) + rect(40, 42, 42, 34, color.bg0, color.green) + rect(172, 42, 42, 34, color.bg0, color.green);
  content += player(108, 84) + silhouette(154, 86, 28, 36, color.green) + tuto(202, 90);
  content += line(140, 104, 162, 104, color.green, 2) + text(160, 134, "+24 회복", 7, color.green, 800, "middle");
  content += badge(18, 10, "2장 회복 불가 스튜디오", color.green) + panel(8, 148, 138, 24) + text(16, 159, "정화 잔량", 6, color.muted) + progress(70, 155, 66, 0.55, color.green);
  return svg(content + chat());
}

function danceGame() {
  let content = header("춤 미션", "박자에 맞춰 방향을 입력합니다.");
  content += panel(32, 44, 256, 100) + line(48, 116, 272, 116, color.cyan, 2);
  [76, 124, 172, 220].forEach((x, index) => {
    content += rect(x, 54 + index * 10, 18, 18, index % 2 ? color.panelHi : color.bg1, index === 2 ? color.cyan : color.outline);
    content += text(x + 9, 67 + index * 10, ["←", "↓", "↑", "→"][index], 9, index === 2 ? color.cyan : color.text, 800, "middle");
  });
  content += player(48, 88) + text(160, 135, "PERFECT  ×  12", 8, color.green, 800, "middle");
  content += progress(84, 28, 152, 0.72, color.cyan);
  return svg(content);
}

function muayThaiGame() {
  let content = header("무에타이 미션", "가드와 반격 타이밍을 익힙니다.");
  content += rect(32, 48, 256, 94, color.panel, color.outline) + rect(52, 62, 216, 64, color.bg1, color.amber);
  content += player(78, 76) + silhouette(202, 76, 34, 46, color.amber);
  content += rect(130, 70, 60, 10, color.outline) + rect(132, 72, 36, 6, color.green) + rect(168, 72, 12, 6, color.amber);
  content += text(160, 64, "반격 구간", 6, color.amber, 700, "middle");
  content += button(108, 130, 104, 16, "가드 유지", true) + text(160, 158, "충격 표현 약화 가능", 6, color.muted, 600, "middle");
  return svg(content);
}

function padThaiGame() {
  let content = header("팟타이 미션", "표시된 순서대로 재료를 조리합니다.");
  content += panel(20, 46, 280, 96) + rect(116, 76, 88, 48, color.bg1, color.amber);
  content += rect(126, 88, 68, 24, color.panelHi) + text(160, 103, "팬", 8, color.text, 800, "middle");
  const ingredients = [[38, "면"], [70, "소스"], [218, "숙주"], [252, "라임"]];
  ingredients.forEach(([x, label], index) => {
    content += panel(x, 64, 28, 28, index === 1) + text(x + 14, 82, label, 6, index === 1 ? color.cyan : color.text, 700, "middle");
  });
  content += text(160, 56, "1  면  →  2  소스  →  3  숙주  →  4  라임", 7, color.text, 700, "middle");
  content += progress(88, 132, 144, 0.62, color.amber) + text(160, 156, "남은 시간  00:18", 7, color.text, 700, "middle");
  return svg(content);
}

function horrorScene() {
  let content = rect(0, 0, 320, 180, color.outline) + rect(24, 18, 224, 146, color.bg1);
  content += rect(38, 28, 40, 120, color.panel) + rect(178, 28, 54, 120, color.panel);
  content += `<path d="M128 112 L238 64 L238 156 Z" fill="#F4E9D522"/>` + player(112, 94) + tuto(196, 72, true);
  content += chat() + badge(12, 8, "4장 꺼진 방송국", color.coral);
  content += panel(10, 150, 136, 22) + text(18, 163, "공포 강도", 6, color.muted) + text(136, 163, "기본", 6, color.text, 700, "end");
  return svg(content);
}

function fakeShutdown() {
  let content = rect(0, 0, 320, 180, color.outline);
  content += text(16, 22, "방송 종료 처리 중…", 7, color.onDarkMuted, 600);
  content += panel(82, 52, 156, 74, false) + text(160, 74, "종료 완료", 12, color.text, 800, "middle");
  content += text(160, 92, "창을 닫아도 안전합니다.", 7, color.muted, 600, "middle");
  content += text(160, 114, "아니야. 아직 보고 있어.", 7, color.coral, 700, "middle");
  content += rect(248, 18, 62, 138, color.bg1, color.coral) + text(256, 34, "잘못된 채팅", 6, color.coral, 700);
  content += text(256, 54, "꺼졌어?", 6, color.muted) + text(256, 70, "아직 보여", 6, color.muted) + text(256, 86, "뒤를 봐", 6, color.coral);
  return svg(content);
}

function titleScreen() {
  let content = room() + portal(246, 28, true) + player(178, 96) + tuto(218, 108, true);
  content += text(14, 31, "이월짱", 22, color.text, 800) + rect(14, 36, 102, 2, color.cyan);
  content += text(14, 51, "로그아웃할 수 없습니다!", 10, color.text, 700);
  content += panel(14, 66, 104, 78);
  const labels = ["새 게임", "이어하기", "설정", "종료"];
  labels.forEach((label, index) => {
    const y = 73 + index * 16;
    content += index === 0 ? cursor(10, y + 5) : "";
    content += button(20, y, 92, index === 0 ? 16 : 12, label, index === 0);
  });
  content += text(14, 169, "비공식 팬메이드 게임", 6, color.muted, 600);
  content += text(306, 169, "v0.1", 6, color.muted, 600, "end");
  return svg(content);
}

function finalDepth() {
  let content = rect(0, 0, 320, 180, color.bg0);
  for (let index = 0; index < 6; index += 1) {
    const x = 20 + index * 50;
    content += rect(x, 20, 24, 128, color.panel, color.outline) + rect(x + 6, 30, 12, 4, index % 2 ? color.coral : color.cyan);
    content += rect(x + 6, 42, 12, 4, color.panelHi) + rect(x + 6, 54, 12, 4, color.panelHi);
  }
  content += portal(132, 38, true) + player(90, 106) + tuto(206, 104, true);
  content += badge(12, 8, "최종장 로그아웃 심층부", color.coral);
  return svg(content);
}

function tutoReveal() {
  let content = rect(0, 0, 320, 180, color.bg0) + panel(24, 24, 272, 132, true);
  content += tuto(74, 68, true) + line(104, 82, 158, 82, color.coral, 2);
  content += rect(164, 54, 74, 58, color.outline, color.coral) + rect(176, 66, 50, 34, color.panel);
  content += text(201, 81, "KEEP", 7, color.coral, 800, "middle") + text(201, 92, "ALIVE", 7, color.coral, 800, "middle");
  content += text(160, 36, "튜토의 원본 명세", 10, color.text, 800, "middle");
  content += text(160, 130, "방송 종료 방지 프로세스", 8, color.coral, 800, "middle");
  content += text(160, 144, "도움을 준 순간과 붙잡은 순간이 모두 기록되어 있다.", 6, color.muted, 600, "middle");
  return svg(content);
}

function finalChoice() {
  let content = header("마지막 선택", "튜토의 권한, 기억, 작별 방식을 결정합니다.");
  const choices = [
    [14, "권한 회수", "통제를 끝낸다", color.coral, false],
    [112, "기억 분리", "기억만 보존한다", color.cyan, true],
    [210, "함께 작별", "책임을 확인한다", color.green, false],
  ];
  for (const [x, title, description, accent, selected] of choices) {
    content += panel(x, 50, 90, 88, selected) + rect(x + 8, 58, 74, 4, accent);
    content += text(x + 45, 82, title, 9, color.text, 800, "middle") + text(x + 45, 101, description, 6, color.muted, 600, "middle");
    content += text(x + 45, 123, selected ? "선택 중" : "검토", 6, selected ? color.cyan : color.muted, 700, "middle");
  }
  return svg(content + footer("결정", "기록 확인"));
}

function endingCard(title, subtitle, accent, symbol) {
  let content = rect(0, 0, 320, 180, color.bg0) + rect(12, 12, 296, 156, color.bg1);
  content += rect(32, 42, 256, 2, accent) + text(160, 72, title, 16, color.text, 800, "middle");
  content += text(160, 92, subtitle, 7, color.muted, 600, "middle");
  content += rect(140, 106, 40, 32, color.panel, accent) + text(160, 128, symbol, 12, accent, 800, "middle");
  content += text(160, 154, "아무 버튼이나 눌러 계속", 6, color.muted, 600, "middle");
  return svg(content);
}

function epilogue() {
  let content = header("동행자 후일담", "선택한 관계가 로그아웃 이후에도 이어집니다.");
  content += panel(40, 46, 240, 94, true) + silhouette(56, 62, 38, 48, color.muted);
  content += text(112, 66, "서윤", 11, color.text, 800) + badge(112, 76, "우정", color.green);
  content += text(112, 99, "현실에서 다시 만날 날짜와 장소를", 7, color.text, 600);
  content += text(112, 112, "구체적으로 정리해 메시지로 남겼다.", 7, color.text, 600);
  content += text(112, 130, "다음 방송은 함께 준비하기로 했다.", 6, color.muted, 600);
  return svg(content + footer("다음 후일담", "크레딧"));
}

const screens = [
  ["02_save_load_flat_v2.svg", saveLoad],
  ["03_settings_accessibility_flat_v1.svg", settings],
  ["04_pause_flat_v1.svg", pause],
  ["05_chapter_card_flat_v1.svg", chapterCard],
  ["06_result_credits_flat_v1.svg", resultCredits],
  ["07_exploration_hud_flat_v1.svg", exploration],
  ["08_dialogue_flat_v1.svg", dialogue],
  ["09_tutorial_flat_v1.svg", tutorial],
  ["10_combat_hud_flat_v1.svg", combat],
  ["11_companion_status_flat_v1.svg", companionStatus],
  ["12_logs_clues_flat_v1.svg", logs],
  ["13_downed_restart_flat_v1.svg", downed],
  ["14_clip_result_flat_v1.svg", clipResult],
  ["15_stream_end_flat_v1.svg", streamEnd],
  ["16_logout_failure_flat_v1.svg", logoutFailure],
  ["17_tuto_intro_flat_v1.svg", tutoIntro],
  ["18_admin_log_flat_v1.svg", adminLog],
  ["19_prologue_hero_flat_v1.svg", prologueHero],
  ["20_candidate_limited_ab_flat_v1.svg", limitedAB],
  ["21_first_impression_flat_v1.svg", firstImpression],
  ["22_candidate_reveal_flat_v1.svg", fullReveal],
  ["23_companion_confirm_flat_v1.svg", companionConfirm],
  ["24_abandon_both_flat_v1.svg", abandonBoth],
  ["25_next_round_flat_v1.svg", nextRound],
  ["26_fixed_companion_flat_v1.svg", fixedCompanion],
  ["27_chapter1_square_flat_v1.svg", squareScene],
  ["28_chapter1_boss_flat_v1.svg", bossScene],
  ["29_chapter2_healing_studio_flat_v1.svg", healingStudio],
  ["30_chapter3_dance_flat_v1.svg", danceGame],
  ["31_chapter3_muay_thai_flat_v1.svg", muayThaiGame],
  ["32_chapter3_pad_thai_flat_v1.svg", padThaiGame],
  ["33_chapter4_horror_flat_v1.svg", horrorScene],
  ["34_chapter4_fake_shutdown_flat_v1.svg", fakeShutdown],
  ["35_final_depth_flat_v1.svg", finalDepth],
  ["36_tuto_reveal_flat_v1.svg", tutoReveal],
  ["37_final_choice_flat_v1.svg", finalChoice],
  ["38_ending_emotional_flat_v1.svg", () => endingCard("감동 엔딩", "끝낼 수 있었기에 함께한 시간이 남았다.", color.amber, "◇")],
  ["39_ending_romance_flat_v1.svg", () => endingCard("로맨스 엔딩", "방송 밖에서 다시 시작하는 약속.", color.coral, "♥")],
  ["40_ending_hidden_flat_v1.svg", () => endingCard("히든 엔딩", "기억은 남고, 통제는 끝났다.", color.cyan, "▣")],
  ["41_ending_get_out_flat_v1.svg", () => endingCard("빨리 꺼져!", "종료 버튼은 두 번 누르지 마세요.", color.coral, "×")],
  ["42_ending_friendship_flat_v1.svg", () => endingCard("우정 엔딩", "다음 방송에서도 서로의 편으로.", color.green, "＋")],
  ["43_companion_epilogue_flat_v1.svg", epilogue],
];

if (isBright) {
  screens.unshift([`01_title_screen_bright_v${brightVersion}.svg`, titleScreen]);
}

for (const [filename, render] of screens) {
  const themedFilename = isBright
    ? filename.replace(/_flat_v\d+\.svg$/, `_bright_v${brightVersion}.svg`)
    : filename;
  fs.writeFileSync(path.join(outputDirectory, themedFilename), render(), "utf8");
}

console.log(`Generated ${screens.length} SVG mockups in ${outputDirectory}`);
