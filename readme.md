sudo systemctl daemon-reload
sudo systemctl enable --now monitor-test.timer
sudo systemctl list-timers | grep monitor-test
