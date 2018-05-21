#!/bin/sh

export QT_QUICK_CONTROLS_MOBILE=true
export QT_SCALE_FACTOR=2
export QT_QUICK_CONTROLS_STYLE=Material
qmlscene contents/ui/ExampleApp.qml
