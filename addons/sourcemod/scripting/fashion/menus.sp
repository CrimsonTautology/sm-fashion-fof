void ShowFashionMenu(FashionableClient fclient)
{
    Menu menu = new Menu(FashionMenuSelected);
    menu.SetTitle("Fistful of Fashion");

    menu.AddItem("1", "Hat", ITEMDRAW_DEFAULT);
    menu.AddItem("2", "Mask", ITEMDRAW_DEFAULT);
    menu.AddItem("3", "Clothes", ITEMDRAW_DEFAULT);
    menu.AddItem("4", "Model", IsModelEnabled() ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

    menu.Display(fclient.Client, 20);
}

int FashionMenuSelected(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
            {
                FashionableClient fclient = FashionableClient(param1);

                char choice[32];
                menu.GetItem(param2, choice, sizeof(choice));

                switch (StringToInt(choice))
                {
                    case 1: { ChangeHatMenu(fclient); }
                    case 2: { ChangeMaskMenu(fclient); }
                    case 3: { ChangeClothesMenu(fclient); }
                    case 4: { ChangeModelMenu(fclient); }

                }
            }
        case MenuAction_End: delete menu;
    }
}

void ChangeHatMenu(FashionableClient fclient)
{
    Menu menu = new Menu(ChangeHatMenuHandler);

    menu.SetTitle("Choose Your Hat");

    menu.AddItem("0", "None", 0 == fclient.Hat ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    menu.AddItem("1", "Harmonica White", 1 == fclient.Hat ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    menu.AddItem("2", "Angel Eyes Black", 2 == fclient.Hat ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    menu.AddItem("3", "Wanderin' Star", 3 == fclient.Hat ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    menu.AddItem("4", "The Hat With No Name", 4 == fclient.Hat ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    menu.AddItem("5", "A Pilgrim's Silverbelly", 5 == fclient.Hat ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    menu.AddItem("6", "Ugly Sombrero", 6 == fclient.Hat ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    menu.AddItem("7", "Abe's Topper", 7 == fclient.Hat ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

    menu.Pagination = MENU_NO_PAGINATION;
    menu.ExitBackButton = true;

    menu.Display(fclient.Client, 20);
}

int ChangeHatMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
            {
                FashionableClient fclient = FashionableClient(param1);

                char choice[32];
                menu.GetItem(param2, choice, sizeof(choice));

                fclient.Hat = StringToInt(choice);
                fclient.Refresh();
            }
        case MenuAction_End: delete menu;
    }
}

void ChangeMaskMenu(FashionableClient fclient)
{
    Menu menu = new Menu(ChangeMaskMenuHandler);

    menu.SetTitle("Choose Your Mask");

    menu.AddItem("0", "None", 0 == fclient.Mask ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    menu.AddItem("1", "White", 1 == fclient.Mask ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    menu.AddItem("2", "Black", 2 == fclient.Mask ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

    menu.Pagination = MENU_NO_PAGINATION;
    menu.ExitBackButton = true;

    menu.Display(fclient.Client, 20);
}

int ChangeMaskMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
            {
                FashionableClient fclient = FashionableClient(param1);

                char choice[32];
                menu.GetItem(param2, choice, sizeof(choice));

                fclient.Mask = StringToInt(choice);
                fclient.Refresh();
            }
        case MenuAction_End: delete menu;
    }
}

void ChangeClothesMenu(FashionableClient fclient)
{
    Menu menu = new Menu(ChangeClothesMenuHandler);

    menu.SetTitle("Choose your clothes");

    menu.AddItem("0", "Buono", 0 == fclient.Clothes ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    menu.AddItem("1", "Brutto", 1 == fclient.Clothes ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    menu.AddItem("2", "Cattivo", 2 == fclient.Clothes ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

    menu.Pagination = MENU_NO_PAGINATION;
    menu.ExitBackButton = true;

    menu.Display(fclient.Client, 20);
}

int ChangeClothesMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
            {
                FashionableClient fclient = FashionableClient(param1);

                char choice[32];
                menu.GetItem(param2, choice, sizeof(choice));

                fclient.Clothes = StringToInt(choice);
                fclient.Refresh();
            }
        case MenuAction_End: delete menu;
    }
}

void ChangeModelMenu(FashionableClient fclient)
{
    Menu menu = new Menu(ChangeModelMenuHandler);
    menu.SetTitle("Choose your Model");

    menu.AddItem("0", "Vigilante");
    menu.AddItem("1", "Desperado");
    menu.AddItem("2", "Bandido");
    menu.AddItem("3", "Ranger");
    menu.AddItem("4", "Ghost");
    menu.AddItem("5", "Skeleton");
    menu.AddItem("6", "Zombie");

    menu.Pagination = MENU_NO_PAGINATION;

    menu.Display(fclient.Client, 20);
}

int ChangeModelMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
            {
                FashionableClient fclient = FashionableClient(param1);

                char choice[32];
                menu.GetItem(param2, choice, sizeof(choice));

                switch (StringToInt(choice))
                {
                    case 0: { fclient.Model = g_VigilanteModelIndex; }
                    case 1: { fclient.Model = g_DesperadoModelIndex; }
                    case 2: { fclient.Model = g_BandidoModelIndex; }
                    case 3: { fclient.Model = g_RangerModelIndex; }
                    case 4: { fclient.Model = g_GhostModelIndex; }
                    case 5: { fclient.Model = g_SkeletonModelIndex; }
                    case 6: { fclient.Model = g_ZombieModelIndex; }
                }

                fclient.Refresh();
            }
        case MenuAction_End: delete menu;
    }
}
