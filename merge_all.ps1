$RepoPath = "C:\CF-IP"
Set-Location $RepoPath

# 1. 拉取两个分支的最新代码
git fetch origin unicom
git fetch origin telecom

# 2. 分别把两个分支的IP文件拉取下来
git show origin/unicom:best_ips.txt > best_ips_unicom.txt
git show origin/telecom:best_ips.txt > best_ips_telecom.txt
git show origin/unicom:full_ips.txt > full_ips_unicom.txt
git show origin/telecom:full_ips.txt > full_ips_telecom.txt

# 3. 合并双网IP
# 合并 best_ips.txt
@"
# 联通优选IP（设备A更新）
"@ | Out-File best_ips.txt -Encoding utf8
Get-Content best_ips_unicom.txt | Out-File best_ips.txt -Append -Encoding utf8
@"

# 电信优选IP（设备B更新）
"@ | Out-File best_ips.txt -Append -Encoding utf8
Get-Content best_ips_telecom.txt | Out-File best_ips.txt -Append -Encoding utf8

# 合并 full_ips.txt
@"
# 联通所有可用IP（设备A更新）
"@ | Out-File full_ips.txt -Encoding utf8
Get-Content full_ips_unicom.txt | Out-File full_ips.txt -Append -Encoding utf8
@"

# 电信所有可用IP（设备B更新）
"@ | Out-File full_ips.txt -Append -Encoding utf8
Get-Content full_ips_telecom.txt | Out-File full_ips.txt -Append -Encoding utf8

# 4. 更新README里的时间戳
$now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
(Get-Content README.MD) -replace "本次更新\*\*: .*", "本次更新: $now" | Set-Content README.MD -Encoding utf8

# 5. 提交并推送到main分支
git add best_ips.txt full_ips.txt README.MD
git commit -m "Merge Unicom + Telecom IPs"
git push origin main

Write-Host "✅ 双网IP合并完成并推送到main分支！"
Read-Host "按回车退出"
