local Stats = {}

-------------
-- BERETTA --
-------------

Stats.Beretta = {
    ["Ammo"] = 16,
    ["MaxAmmo"] = 16,

    ["BodyshotDamage"] = 14,
    ["HeadshotDamage"] = 20,

    ["ShootConfig"] = "SemiAuto",
    ["ShootDelay"] = 0.1,

    ["BurstDelay"] = 0.1,
}

-----------
-- GALIL --
-----------

Stats.Galil = {
    ["Ammo"] = 30,
    ["MaxAmmo"] = 30,

    ["BodyshotDamage"] = 28,
    ["HeadshotDamage"] = 41,

    ["ShootConfig"] = "FullAuto",
    ["ShootDelay"] = 0.1,

    ["BurstDelay"] = 0.1,
}

----------
-- M4A1 --
----------

Stats.M4A1 = {
    ["Ammo"] = 25,
    ["MaxAmmo"] = 25,

    ["BodyshotDamage"] = 23,
    ["HeadshotDamage"] = 31,

    ["ShootConfig"] = "FullAuto",
    ["ShootDelay"] = 0.1,

    ["BurstDelay"] = 0.1,
}

--[[
    Weapon: M4A1

    Weight: 3.52 kg
    Barrel Length: 368 mm
    Firemode: Semi, Burst, Auto
    Firerate: 700–950RPM

    Cartridge: 5.56×45mm NATO
    Weight:  62 gr
    Muzzle Velocity: 922 m/s
]]

return Stats