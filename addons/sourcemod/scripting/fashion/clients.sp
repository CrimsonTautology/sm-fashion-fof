#define MAX_CLOTHES 3
#define MAX_MASKS 3
#define MAX_HATS 8
#define MAX_MODELS 6

#define HAT_OFFSET 2
#define MASK_OFFSET 16

int g_Clothes[MAXPLAYERS+1] = {0, ...};
int g_Hat[MAXPLAYERS+1] = {0, ...};
int g_Mask[MAXPLAYERS+1] = {0, ...};

Cookie g_ClothesCookie;
Cookie g_HatCookie;
Cookie g_MaskCookie;
Cookie g_WasRandomizedCookie;

methodmap FashionableClient
{
    /** FashionableClient
      Represents a client in game that can have their cosmetic apperance
      modified.
     */
    public FashionableClient(int client)
    {
        return view_as<FashionableClient>(client);
    }

    property int Client
    {
        public get() { return view_as<int>(this); }
    }

    property int Clothes
    {
        public get() { return g_Clothes[this.Client]; }
        public set(int clothes) 
        {
            if(clothes < 0 || clothes >= MAX_CLOTHES) return;

            char tmp[11];
            IntToString(clothes, tmp, sizeof(tmp));

            g_Clothes[this.Client] = clothes;
            g_ClothesCookie.Set(this.Client, tmp);
        }
    }

    property int Hat
    {
        public get() { return g_Hat[this.Client]; }
        public set(int hat) 
        {
            if(hat < 0 || hat >= MAX_HATS) return;

            char tmp[11];
            IntToString(hat, tmp, sizeof(tmp));

            g_Hat[this.Client] = hat;
            g_HatCookie.Set(this.Client, tmp);
        }
    }

    property int Mask
    {
        public get() { return g_Mask[this.Client]; }
        public set(int mask) 
        {
            if(mask < 0 || mask >= MAX_MASKS) return;

            char tmp[11];
            IntToString(mask, tmp, sizeof(tmp));

            g_Mask[this.Client] = mask;
            g_MaskCookie.Set(this.Client, tmp);
        }
    }

    property int Model
    {
        public get() { 
            return GetEntProp(this.Client, Prop_Data, "m_nModelIndex");
        }
        public set(int index) {
            SetEntProp(this.Client, Prop_Data, "m_nModelIndex", index, 2);
        }
    }

    property int BodyGroup
    {
        public set(int body_group) {
            SetEntProp(this.Client, Prop_Data, "m_nBody", body_group);
        }
    }

    property int Skin
    {
        public set(int skin) {
            SetEntProp(this.Client, Prop_Data, "m_nSkin", skin);
        }
    }

    public void Randomize()
    {
        this.Clothes = GetRandomInt(0, MAX_CLOTHES - 1);
        this.Mask = GetRandomInt(0, MAX_MASKS - 1); 
        this.Hat = GetRandomInt(0, MAX_HATS - 1);
        g_WasRandomizedCookie.Set(this.Client, "1");
    }

    public void Refresh()
    {
        int body_group;
        int skin;
        
        // Bandidos and Rangers can not have non-default skins
        if(this.Model == g_BandidoModelIndex || this.Model == g_RangerModelIndex) {
            skin = 0;

        } else {
            skin = this.Clothes;
        }

        // Vigilantes need to invert the first two hats
        if(this.Model == g_VigilanteModelIndex && this.Hat == 1) {
            body_group = (2 * HAT_OFFSET) + (this.Mask * MASK_OFFSET);

        } else if(this.Model == g_VigilanteModelIndex && this.Hat == 2) {
            body_group = (1 * HAT_OFFSET) + (this.Mask * MASK_OFFSET);


        // skeletons can only have one type of hat, and must be manually set
        } else if (this.Model == g_SkeletonModelIndex && this.Hat > 0)
        {
            body_group = 1;


        // Rangers can not have the first(white) hat but there is nothing to
        // address here. Bandidos and Rangers can not have the second(black) mask
        // but there is nothing to address here
        } else {
            body_group = (this.Hat * HAT_OFFSET) + (this.Mask * MASK_OFFSET);

        }

        this.BodyGroup = body_group;
        this.Skin = skin;
    }

    public void LoadFromCookies()
    {
        char buffer[11];
        int type_of;

        g_ClothesCookie.Get(this.Client, buffer, sizeof(buffer));
        type_of = StringToInt(buffer);
        if (strlen(buffer) > 0 && type_of < MAX_CLOTHES){
            g_Clothes[this.Client] = type_of;
        }else{
            g_Clothes[this.Client] = 0;
        }

        g_HatCookie.Get(this.Client, buffer, sizeof(buffer));
        type_of = StringToInt(buffer);
        if (strlen(buffer) > 0 && type_of < MAX_HATS){
            g_Hat[this.Client] = type_of;
        }else{
            g_Hat[this.Client] = 0;
        }

        g_MaskCookie.Get(this.Client, buffer, sizeof(buffer));
        type_of = StringToInt(buffer);
        if (strlen(buffer) > 0 && type_of < MAX_MASKS){
            g_Mask[this.Client] = type_of;
        }else{
            g_Mask[this.Client] = 0;
        }

        g_WasRandomizedCookie.Get(this.Client, buffer, sizeof(buffer));
        if (!view_as<bool>(StringToInt(buffer))){
            this.Randomize();
        }
    }
}
