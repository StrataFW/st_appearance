
local db = {}

---@param table_ string
---@param column string
---@param ddl string
local function addColumnIfMissing(table_, column, ddl)
    local exists <const> = MySQL.scalar.await(
        "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?",
        { table_, column }
    ) or 0

    if exists == 0 then
        MySQL.query.await(("ALTER TABLE `%s` ADD COLUMN %s"):format(table_, ddl))
    end
end

---@param identifier string
---@return string?
function db.getSkin(identifier)
    return MySQL.scalar.await(
        "SELECT skin FROM st_appearance WHERE identifier = ?",
        { identifier }
    )
end

---@param identifier string
---@param skin table
function db.upsertSkin(identifier, skin)
    MySQL.insert.await(
        "INSERT INTO st_appearance (identifier, skin) VALUES (?, ?) ON DUPLICATE KEY UPDATE skin = VALUES(skin)",
        { identifier, json.encode(skin) }
    )
end

---@param identifier string
---@return table[]
function db.listPresets(identifier)
    return MySQL.query.await(
        "SELECT * FROM st_appearance_presets WHERE identifier = ? ORDER BY created_at DESC",
        { identifier }
    ) or {}
end

---@param identifier string
---@param preset { id:string, name:string, tags?:table, data:table, shareCode?:string, createdAt:number }
function db.insertPreset(identifier, preset)
    MySQL.insert(
        "INSERT INTO st_appearance_presets (identifier, preset_id, name, tags, data, share_code, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
        {
            identifier,
            preset.id,
            preset.name,
            json.encode(preset.tags or {}),
            json.encode(preset.data),
            preset.shareCode,
            preset.createdAt,
        }
    )
end

---@param identifier string
---@param presetId string
function db.deletePreset(identifier, presetId)
    MySQL.query(
        "DELETE FROM st_appearance_presets WHERE identifier = ? AND preset_id = ?",
        { identifier, presetId }
    )
end

---@param identifier string
---@return table[]
function db.listOutfits(identifier)
    return MySQL.query.await(
        "SELECT id, identifier, outfit_id, name, category, data, share_code, favorite, created_at, tags FROM st_appearance_outfits WHERE identifier = ? ORDER BY created_at DESC",
        { identifier }
    ) or {}
end

---@param identifier string
---@param outfit { id:string, name:string, category?:string, data:table, shareCode?:string, favorite?:boolean, createdAt:number, tags?:table }
function db.insertOutfit(identifier, outfit)
    MySQL.insert(
        "INSERT INTO st_appearance_outfits (identifier, outfit_id, name, category, data, share_code, favorite, created_at, tags) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        {
            identifier,
            outfit.id,
            outfit.name,
            outfit.category or "custom",
            json.encode(outfit.data),
            outfit.shareCode,
            outfit.favorite and 1 or 0,
            outfit.createdAt,
            json.encode(outfit.tags or {}),
        }
    )
end

---@param identifier string
---@param outfitId string
function db.deleteOutfit(identifier, outfitId)
    MySQL.query(
        "DELETE FROM st_appearance_outfits WHERE identifier = ? AND outfit_id = ?",
        { identifier, outfitId }
    )
end

---@param identifier string
---@param outfitId string
---@param fields { name:string, category:string, favorite:boolean, tags:table }
function db.updateOutfit(identifier, outfitId, fields)
    MySQL.query(
        "UPDATE st_appearance_outfits SET name = ?, category = ?, favorite = ?, tags = ? WHERE identifier = ? AND outfit_id = ?",
        {
            fields.name,
            fields.category,
            fields.favorite and 1 or 0,
            json.encode(fields.tags or {}),
            identifier,
            outfitId,
        }
    )
end

---@param identifier string
---@return table[]
function db.listWardrobe(identifier)
    return MySQL.query.await(
        "SELECT slot, name, data, updated_at FROM st_appearance_wardrobe WHERE identifier = ? ORDER BY slot ASC",
        { identifier }
    ) or {}
end

---@param identifier string
---@param slot number
---@param entry { name:string, data:table, updatedAt:number }
function db.upsertWardrobeSlot(identifier, slot, entry)
    MySQL.insert(
        [[
            INSERT INTO st_appearance_wardrobe (identifier, slot, name, data, updated_at)
            VALUES (?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                name       = VALUES(name),
                data       = VALUES(data),
                updated_at = VALUES(updated_at)
        ]],
        { identifier, slot, entry.name, json.encode(entry.data), entry.updatedAt }
    )
end

---@param identifier string
---@param slot number
function db.deleteWardrobeSlot(identifier, slot)
    MySQL.query(
        "DELETE FROM st_appearance_wardrobe WHERE identifier = ? AND slot = ?",
        { identifier, slot }
    )
end

---@param identifier string
---@param jobName string
---@param data table
function db.upsertJobOutfit(identifier, jobName, data)
    MySQL.insert(
        "INSERT INTO st_appearance_job_outfits (identifier, job, data) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE data = VALUES(data)",
        { identifier, jobName, json.encode(data) }
    )
end

---@param identifier string
---@param jobName string
---@return table?
function db.getJobOutfit(identifier, jobName)
    local raw <const> = MySQL.scalar.await(
        "SELECT data FROM st_appearance_job_outfits WHERE identifier = ? AND job = ?",
        { identifier, jobName }
    )
    return raw and json.decode(raw) or nil
end

---@param faction string
---@param kind string
---@param uniformId string
---@return boolean
function db.uniformExists(faction, kind, uniformId)
    return MySQL.scalar.await(
        "SELECT id FROM st_appearance_faction_uniforms WHERE faction = ? AND kind = ? AND uniform_id = ?",
        { faction, kind, uniformId }
    ) ~= nil
end

---@param faction string
---@param kind string
---@return number
function db.uniformCount(faction, kind)
    return MySQL.scalar.await(
        "SELECT COUNT(*) FROM st_appearance_faction_uniforms WHERE faction = ? AND kind = ?",
        { faction, kind }
    ) or 0
end

---@param faction string
---@param kind string
---@param uniform { id:string, name:string, minGrade:number, data:table }
---@param createdBy string?
function db.upsertUniform(faction, kind, uniform, createdBy)
    MySQL.insert(
        [[
            INSERT INTO st_appearance_faction_uniforms
                (faction, kind, uniform_id, name, min_grade, data, created_by, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                name      = VALUES(name),
                min_grade = VALUES(min_grade),
                data      = VALUES(data)
        ]],
        { faction, kind, uniform.id, uniform.name, uniform.minGrade, json.encode(uniform.data), createdBy, os.time() }
    )
end

---@param faction string
---@param kind string
---@param uniformId string
function db.deleteUniform(faction, kind, uniformId)
    MySQL.query(
        "DELETE FROM st_appearance_faction_uniforms WHERE faction = ? AND kind = ? AND uniform_id = ?",
        { faction, kind, uniformId }
    )
end

---@param faction string
---@param kind string
---@return table[]
function db.listUniforms(faction, kind)
    return MySQL.query.await(
        "SELECT uniform_id AS id, name, min_grade AS minGrade, data, created_at AS createdAt FROM st_appearance_faction_uniforms WHERE faction = ? AND kind = ? ORDER BY name ASC",
        { faction, kind }
    ) or {}
end

---@param code string
---@return boolean
function db.shareCodeExists(code)
    return MySQL.scalar.await(
        "SELECT 1 FROM st_appearance_share_codes WHERE code = ?",
        { code }
    ) ~= nil
end

---@param code string
---@param identifier string
---@param kind string
---@param payload table
---@param maxUses number
---@param expiresAt number?
---@param createdAt number
function db.insertShareCode(code, identifier, kind, payload, maxUses, expiresAt, createdAt)
    MySQL.insert(
        [[
            INSERT INTO st_appearance_share_codes
                (code, identifier, kind, payload, max_uses, uses, expires_at, created_at)
            VALUES (?, ?, ?, ?, ?, 0, ?, ?)
        ]],
        { code, identifier, kind, json.encode(payload), maxUses, expiresAt, createdAt }
    )
end

---@param code string
---@return table?
function db.findShareCode(code)
    return MySQL.single.await(
        "SELECT * FROM st_appearance_share_codes WHERE code = ?",
        { code }
    )
end

---@param code string
function db.incrementShareCodeUses(code)
    MySQL.query(
        "UPDATE st_appearance_share_codes SET uses = uses + 1 WHERE code = ?",
        { code }
    )
end

---@param code string
---@param identifier string
---@return boolean
function db.deleteShareCode(code, identifier)
    local affected <const> = MySQL.update.await(
        "DELETE FROM st_appearance_share_codes WHERE code = ? AND identifier = ?",
        { code, identifier }
    ) or 0
    return affected > 0
end

---@param identifier string
---@return table[]
function db.listShareCodes(identifier)
    return MySQL.query.await(
        "SELECT code, kind, max_uses, uses, expires_at, created_at FROM st_appearance_share_codes WHERE identifier = ? ORDER BY created_at DESC",
        { identifier }
    ) or {}
end

MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `st_appearance` (
            `identifier` VARCHAR(60) NOT NULL,
            `skin`       LONGTEXT    NOT NULL,
            PRIMARY KEY (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `st_appearance_presets` (
            `id`         INT          NOT NULL AUTO_INCREMENT,
            `identifier` VARCHAR(60)  NOT NULL,
            `preset_id`  VARCHAR(60)  NOT NULL,
            `name`       VARCHAR(100) NOT NULL,
            `tags`       TEXT         DEFAULT NULL,
            `data`       LONGTEXT     NOT NULL,
            `share_code` VARCHAR(20)  DEFAULT NULL,
            `created_at` BIGINT       NOT NULL,
            PRIMARY KEY (`id`),
            KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `st_appearance_outfits` (
            `id`         INT          NOT NULL AUTO_INCREMENT,
            `identifier` VARCHAR(60)  NOT NULL,
            `outfit_id`  VARCHAR(60)  NOT NULL,
            `name`       VARCHAR(100) NOT NULL,
            `category`   VARCHAR(30)  DEFAULT 'custom',
            `data`       LONGTEXT     NOT NULL,
            `share_code` VARCHAR(20)  DEFAULT NULL,
            `favorite`   TINYINT(1)   DEFAULT 0,
            `created_at` BIGINT       NOT NULL,
            PRIMARY KEY (`id`),
            KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `st_appearance_job_outfits` (
            `id`         INT          NOT NULL AUTO_INCREMENT,
            `identifier` VARCHAR(60)  NOT NULL,
            `job`        VARCHAR(60)  NOT NULL,
            `data`       LONGTEXT     NOT NULL,
            PRIMARY KEY (`id`),
            UNIQUE KEY `identifier_job` (`identifier`, `job`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `st_appearance_faction_uniforms` (
            `id`         INT          NOT NULL AUTO_INCREMENT,
            `faction`    VARCHAR(60)  NOT NULL,
            `kind`       VARCHAR(10)  NOT NULL DEFAULT 'job',
            `uniform_id` VARCHAR(60)  NOT NULL,
            `name`       VARCHAR(100) NOT NULL,
            `min_grade`  INT          NOT NULL DEFAULT 0,
            `data`       LONGTEXT     NOT NULL,
            `created_by` VARCHAR(60)  DEFAULT NULL,
            `created_at` BIGINT       NOT NULL,
            PRIMARY KEY (`id`),
            UNIQUE KEY `faction_kind_uniform` (`faction`, `kind`, `uniform_id`),
            KEY `faction` (`faction`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `st_appearance_share_codes` (
            `code`       VARCHAR(20) NOT NULL,
            `identifier` VARCHAR(60) NOT NULL,
            `kind`       VARCHAR(20) NOT NULL DEFAULT 'outfit',
            `payload`    LONGTEXT    NOT NULL,
            `max_uses`   INT         NOT NULL DEFAULT 0,
            `uses`       INT         NOT NULL DEFAULT 0,
            `expires_at` BIGINT      DEFAULT NULL,
            `created_at` BIGINT      NOT NULL,
            PRIMARY KEY (`code`),
            KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `st_appearance_wardrobe` (
            `id`         INT          NOT NULL AUTO_INCREMENT,
            `identifier` VARCHAR(60)  NOT NULL,
            `slot`       INT          NOT NULL,
            `name`       VARCHAR(100) NOT NULL,
            `data`       LONGTEXT     NOT NULL,
            `updated_at` BIGINT       NOT NULL,
            PRIMARY KEY (`id`),
            UNIQUE KEY `identifier_slot` (`identifier`, `slot`),
            KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    addColumnIfMissing("st_appearance_outfits", "tags", "`tags` TEXT DEFAULT NULL")

    local tables = {
        "st_appearance", "st_appearance_presets", "st_appearance_outfits",
        "st_appearance_job_outfits", "st_appearance_faction_uniforms",
        "st_appearance_share_codes", "st_appearance_wardrobe",
    }
    for i = 1, #tables do
        MySQL.query.await(
            ("ALTER TABLE `%s` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"):format(tables[i])
        )
    end
end)

return db
