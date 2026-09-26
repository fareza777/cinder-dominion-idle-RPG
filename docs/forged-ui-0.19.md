# Forged interface — 0.19

Original code-authored SVG frames replace generic rounded flat cards and controls across the shared UI. Three templates distinguish ornamented panels, metal buttons and recessed fields. Their corners and edge margins are preserved by StyleBoxTexture nine-patch rendering; color variants are rasterized and cached once per palette instead of regenerated each frame.

The central reading surface stays quiet. Ornament is confined to edges; warm ivory text sits on dark slate or bronze. Primary buttons use bronze with light text, while hover/focus/pressed and disabled states remain distinct. Headers, navigation and the bottom activity bar use the same material system.

The shared Theme covers LineEdit (including SpinBox), TextEdit, OptionButton, PopupMenu, CheckButton, sliders and scrollbars. Custom vector switches and slider gems replace default control imagery. Native operating-system file dialogs remain native.

The first visual pass revealed short button words wrapping because new frame padding exceeded their old width budget. Button minimum width now includes the new inset, and wrapping occurs at word boundaries. Existing 48px minimum button height and scrollable dialog bodies remain intact. At 130% text, content grows vertically rather than being overlaid by ornaments.

Templates are text assets loaded at runtime, explicitly included by the Android exporter. No generated raster art, external service, new save field or economy change. All new assets are original vectors authored in this repository.
