---@meta

---@class st_appearance.Appearance
---@field model?    string|integer
---@field clothing? table
---@field props?    table
---@field tattoos?  table
---@field hair?     table
---@field [string]  any

---@class st_appearance.Outfit
---@field id        string
---@field name      string
---@field category? string
---@field data      table
---@field shareCode? string
---@field favorite? boolean
---@field createdAt? integer
---@field tags?     string[]

---@class st_appearance.Preset
---@field id        string
---@field name      string
---@field tags?     string[]
---@field data      table
---@field createdAt? integer
---@field shareCode? string

---@class st_appearance.WardrobeSlot
---@field slot      integer
---@field name      string
---@field data      table
---@field updatedAt integer

---@class st_appearance.Uniform
---@field id        string
---@field name      string
---@field minGrade? integer
---@field data      table

---@class st_appearance.ShareCode
---@field code       string
---@field identifier string
---@field kind       string
---@field payload    table
---@field maxUses    integer
---@field uses       integer
---@field expiresAt? integer
---@field createdAt  integer
