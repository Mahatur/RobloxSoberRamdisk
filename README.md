# RobloxSoberRamdisk

for game: https://github.com/vinegarhq/sober

> 🚀 Ultra-fast loading for Roblox Sober Flatpak on Linux — reduce launch time from 30s (SSD) or 5 min (HDD) down to ~3 seconds in RAM

---

## ❗ Important Notes

✅ Works on **any Linux distro** that supports Flatpak

❎ Doesn't work on **Windows, MACos, Android, IOS, ChromeOS or whatever non linux**

💾 Requires **at least ~4GB of RAM**  

⚠️ **All data in RAMDisk is lost on shutdown** So make sure you logged in before offloading it into ram.

📁 Offloads `~/.var/app/org.vinegarhq.Sober` into RAM

---

## 🛠️ How It Works

This script mounts a `tmpfs` RAMDisk, copies Roblox Sober files into it, and allows Flatpak to use that instead of slow disk storage.

### Benefits:

- ⚡ Instant launch
- 💾 No SSD wear (which is why SSD makers hate me)
- 🧊 No HDD bottlenecks (no more clicking noises)
- 🌐 Universal (as long as Flatpak works)

---

## 🚀 Usage

```bash
git clone https://github.com/Mahatur/RobloxSoberRamdisk
cd RobloxSoberRamdisk
chmod +x Soberam.sh
./Soberam.sh
```

Once finished, run Roblox Sober:

`flatpak run org.vinegarhq.Sober`

To remove it from ramdisk, run:

`./Soberam.sh -r`

📜 Script Logic Summary

Mounts /home/you/sober-ramdisk as tmpfs (4GB, or you can adjust it)

Copies data from ~/.var/app/org.vinegarhq.Sober to **RAM / TMPFS**

Progress shown during copy

Grants full read/write permission

Overrides Flatpak to use the new location

📝 NOTE

If you don't have sufficient memory, use ZRAM (Do not swap to disk, i swear to god, it's the same as not using ramdisk)

⚠️ SSD Makers Might Hate This

This script completely bypasses storage I/O, reducing SSD/HDD usage to zero during gameplay

No copyright, This just for speed improvement.
Use at your own discretion.
