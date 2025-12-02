-- 获取游戏主模组"KeZhan"和事件模组"_Event"
local KeZhan = GameMain:GetMod("KeZhan");
local tbEvent = GameMain:GetMod("_Event");

-- 定义NPC状态数组和ID数组
local NPCING = {0,0,0,0}  -- 用于跟踪4个NPC的状态（0=未入住，1=已入住）
local ID = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,1000,1001,1002,1003,1004,1005,1006,1007,1008,1009,1010,1011,1012,1013,1014,1015,1016,1017,1018,1019,1020,1021,1022,1023,1024,1025,1026,1027,1028,1029,1030,1031,1032,1033,1034,1035,1036,1037,1038,1039,1040,1041,1042,1043,1044,1045,1046,1047,1048,1049,1050,1051,1052,1053,1054,1055,1056,1057,1058,1059,1060,1061,1062,1063,1064,1065,1066,1067,1068,1069,2001,2002,2003,2004,2005,2006,2007,2008,3001,10001,10002,10003,10004}

-- 定义空表用于存储新旧ID和轮回NPC信息
local NewID = {}
local OldID = {}
local LunHui = {}

-- 模组初始化函数
function KeZhan:OnInit()
    -- 添加重置按钮到游戏界面
    self:AddResetButton()
end

-- 进入游戏时执行的函数
function KeZhan:OnEnter()
    -- 注册秘境更新事件，当秘境更新时调用KeZhan.OnSecretUpdate函数
    tbEvent:RegisterEvent(g_emEvent.SecretUpdate, KeZhan.OnSecretUpdate, "KeZhan")
    -- 确保重置按钮存在
    self:AddResetButton()
end

-- 添加重置按钮到游戏界面
function KeZhan:AddResetButton()
    -- 检查是否已经存在重置按钮，避免重复创建
    if self.resetButton then
        return
    end
    
    -- 创建重置按钮（这里假设使用游戏内的UI创建方法）
    -- 具体实现可能需要根据游戏的UI系统进行调整
    self.resetButton = CS.XiaWorld.UI.Button:new()
    self.resetButton.Text = "重置已标记NPC"
    self.resetButton.Size = Vector2(120, 30)
    self.resetButton.Position = Vector2(10, 100)  -- 屏幕左上角位置
    
    -- 绑定点击事件
    self.resetButton:AddClickEvent(function()
        self:ResetMarkedNPCs()
    end)
    
    -- 将按钮添加到游戏界面
    -- 具体添加方法需要根据游戏UI系统调整
    if GameMain.UI then
        GameMain.UI:AddChild(self.resetButton)
    end
end

-- 重置已标记的NPC函数
function KeZhan:ResetMarkedNPCs()
    -- 清空已标记的NPC表
    OldID = {}
    
    -- 重置所有客栈房间状态
    for i = 1, #NPCING do
        NPCING[i] = 0
    end
    
    -- 显示重置成功消息
    self:ShowMessage("已重置所有标记的NPC，客栈房间已清空！")
    
    -- 打印日志（可选）
    print("[KeZhan Mod] 已重置所有标记的NPC和客栈房间状态")
end

-- 显示消息函数
function KeZhan:ShowMessage(msg)
    -- 使用游戏内的消息系统显示提示
    if GameMain.ShowMessage then
        GameMain:ShowMessage(msg)
    else
        -- 备用方案：在控制台输出
        print(msg)
    end
end

-- 离开游戏时执行的函数
function KeZhan:OnLeave()
    -- 注销秘境更新事件
    tbEvent:UnRegisterEvent(g_emEvent.SecretUpdate, "KeZhan")
    
    -- 清理重置按钮
    if self.resetButton then
        self.resetButton:Destroy()
        self.resetButton = nil
    end
end

-- 秘境更新事件处理函数
function KeZhan.OnSecretUpdate(t,obj)
    -- 检查客栈是否被锁定
    if PlacesMgr:IsLocked("Place_KeZhan") == true then
        -- 如果拥有特定秘境（ID=27961），则解锁客栈并隐藏该秘境
        if MapStoryMgr:HasSecret(27961) == true then
            PlacesMgr:UnLockPlace("Place_KeZhan");
            MapStoryMgr:GetSecretDef(27961).Hide = true
        end
    end
end

-- 获取随机模组NPC的ID
function KeZhan:GeRandomModNpc()
    NewID = {};
    -- 遍历所有轮回NPC的ID
    for k,v in pairs(NpcMgr:GetReincarnateIDs()) do
        -- 过滤条件：索引>=107，排除特定ID，且不在OldID表中的NPC
        if k >= 107 and v ~= 5288 and v ~= 5289 and v ~= 5290 and v ~= 5291 and OldID[v] == nil then
            NewID[k] = v;  -- 将符合条件的NPCID添加到NewID表
        end
    end
    return NewID;
end

-- 获取所有模组NPC的ID（以数组形式返回）
function KeZhan:GetAllModNpcID()
    NewID = {};
    local i = 1;
    for k,v in pairs(NpcMgr:GetReincarnateIDs()) do
        if k >= 107 and v ~= 5288 and v ~= 5289 and v ~= 5290 and v ~= 5291 and OldID[v] == nil then
            NewID[i] = v;  -- 使用连续数字索引存储NPCID
            i = i + 1;
        end
    end
    return NewID;
end

-- 获取所有模组NPC的姓名
function KeZhan:GetAllModNpcName()
    NewID = {};
    LunHui = {}
    local i = 1;
    -- 首先获取所有符合条件的NPCID
    for k,v in pairs(NpcMgr:GetReincarnateIDs()) do
        if k >= 107 and v ~= 5288 and v ~= 5289 and v ~= 5290 and v ~= 5291 and OldID[v] == nil then
            NewID[i] = v;
            i = i + 1;
        end
    end
    
    -- 根据NPCID获取对应的姓名（姓氏+名字）
    for k,v in pairs(NewID) do
        local npcData = NpcMgr:GetReincarnateDataByID(v)
        LunHui[k] = npcData.LastName..npcData.FristName
    end
    
    -- 在列表末尾添加"离开此地"选项
    LunHui[#LunHui + 1] = "离开此地"
    return LunHui;
end

-- 将NPCID添加到OldID表（标记为已处理）
function KeZhan:AddOldID(ID)
    OldID[ID] = 1;
end

-- 检查指定位置的NPC状态
function KeZhan:GetNPC(i)
    if NPCING[i] == 0 then
        return true;  -- 返回true表示该位置可用（NPC未入住）
    else
        return false; -- 返回false表示该位置已被占用
    end
end

-- 标记指定位置为已被NPC占用
function KeZhan:AddNPC(i)
    NPCING[i] = 1;
    return
end

-- 随机获取一个ID
function KeZhan:GetID()
    world:SetRandomSeed()  -- 设置随机种子
    local id = me:RandomInt(1,#ID)  -- 生成1到ID表长度的随机整数
    return ID[id];  -- 返回随机ID
end

-- 游戏保存时调用的函数
function KeZhan:OnSave()
    -- 保存NPC状态和已处理ID表
    local tbSave = { 
        index1 = NPCING,  -- NPC状态数组
        index2 = OldID    -- 已处理的NPCID表
    };
    return tbSave;
end

-- 游戏加载时调用的函数
function KeZhan:OnLoad(tbLoad)
    if tbLoad ~= nil then
        NPCING = tbLoad["index1"];  -- 加载NPC状态
        OldID = tbLoad["index2"]    -- 加载已处理的NPCID
    end
end
