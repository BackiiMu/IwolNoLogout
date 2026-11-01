# UI 시안 재생성 도구

`art/mockups/`의 평면 픽셀 UI 시안을 다시 만들기 위한 로컬 도구다. 게임 실행과는 무관하다.

## SVG 생성

저장소 루트에서 실행한다.

```bash
node tools/mockups/generate_all_mockups.js art/mockups bright
```

`bright` 테마는 `01`부터 `43`까지의 순백·하늘색 `bright_v2` SVG를 생성한다. 테마 인수를 생략하면 이전 어두운 평면 시안 `02`부터 `43`을 재생성한다.

## PNG 미리보기 생성

macOS에서는 화면을 띄우지 않는 WebKit 렌더러를 사용할 수 있다.

```bash
swiftc tools/mockups/render_svg.swift -o /tmp/iwol_render_svg
/tmp/iwol_render_svg art/mockups/02_save_load_bright_v2.svg art/mockups/02_save_load_bright_v2.png .
swiftc tools/mockups/make_contact_sheet.swift -o /tmp/iwol_contact_sheet
/tmp/iwol_contact_sheet art/mockups/contact_sheets/bright/01_common_bright_v2.png 3 --bright art/mockups/0{1,2,3,4,5,6}_*_bright_v2.png
```

Windows 또는 Linux에서는 SVG를 지원하는 브라우저나 디자인 도구에서 `1280x720` PNG로 내보낸다.

## 관리 규칙

- SVG가 편집 가능한 기준 원본이다.
- PNG는 검토와 문서 공유용 미리보기다.
- 공통 색상과 간격은 `docs/UI_DESIGN_SYSTEM.md`를 따른다.
- 후보 외형이 확정되기 전에는 중립 실루엣을 유지한다.
- AI 생성 이미지는 최종 UI 기준으로 사용하지 않는다.
