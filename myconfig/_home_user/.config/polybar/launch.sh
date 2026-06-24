#!/bin/bash

# 如果你所有的 bar 都启用了 ipc，你也可以使用
# polybar-msg cmd quit
# 终止正在运行的 bar 实例
killall -q polybar

# 等待直到所有 polybar 进程完全终止
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.1; done

# 获取所有连接的显示器列表
MONITORS=$(polybar -m | awk -F '[:+]' '{print $1}')

# 为每个显示器启动polybar
for monitor in $MONITORS; do
    export MONITOR=$monitor

    # 运行 Polybar，使用默认的配置文件路径 ~/.config/polybar/config.ini
    polybar -r -c ~/.config/polybar/config.ini mybar 2>&1 | tee -a /tmp/polybar-$monitor.log & disown
    
    echo "Polybar launched on $monitor"
done

echo "All polybar launched..."
