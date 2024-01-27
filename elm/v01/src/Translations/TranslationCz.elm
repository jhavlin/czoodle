module Translations.TranslationCz exposing (translationCz)

import Translations.Translation exposing (Translation)


translationCz : Translation
translationCz =
    { code = "CZ"
    , name = "Ovládání v češtině"
    , common =
        { projectTitleLabel = "Název:"
        , projectTitlePlaceholder = "např. Teambuilding, dárek pro tetu, nebo třeba sraz baletek"
        , pollTypeGeneric = "Obecné"
        , pollTypeDate = "Datum"
        , pollTitleLabel = "Nadpis:"
        , pollDescriptionLabel = "Popis:"
        , pollOptionsLabel = "Možnosti:"
        , untitled = "(bez názvu)"
        , waitPlease = "Čekejte, prosím."
        , remove = "Odstranit"
        , today = "Dnes"
        , monthNames = [ "Leden", "Únor", "Březen", "Duben", "Květen", "Červen", "Červenec", "Srpen", "Září", "Říjen", "Listopad", "Prosinec" ]
        , dayNamesShort = [ "Po", "Út", "St", "Čt", "Pá", "So", "Ne" ]
        , error = "Chyba"
        , saveChanges = "Uložit změny"
        , cancel = "Zrušit"
        }
    , vote =
        { loading = "Nahrávám"
        , saving = "Ukládám"
        , editProjectTitle = "Upravit projekt (Nepovolaným osobám vstup zapovězen!)"
        , legend = "Legenda"
        , yes = "Ano"
        , no = "Ne"
        , ifNeeded = "V nouzi"
        , poll = "Hlasování"
        , revertRowButtonTitle = "Zapomeň a zruš úpravy v tomto řádku."
        , editRowButtonTitle = "Uprav tento řádek. Pamatujte, prosím, že měnit hlasování ostatních bez dovolení není hezké!"
        , rowForDeletion = "Ke smazání"
        , rowActionRevert = "Vrať"
        , rowActionDelete = "Smaž"
        , rowActionDeleteTitle = "Smaž řádek pouze v tomto hlasování"
        , addRow = "+ Přidej člověka"
        , addRowTitle = "Přidej nového hlasujícího do všech hlasování"
        , clearEmptyRows = "Odeber nevyplněné"
        , clearEmptyRowsTitle = "Odebrat řádky s nevyplněným jménem ze všech hlasování"
        , enterName = "Vyplňte jméno!"
        , newPerson = "(nový hlasující)"
        }
    , editProject =
        { scrollDownButtonTitle = "Přejít dolů a uložit nebo zrušit"
        , switchBackButtonTitle = "Přepnout zpět na hlasování"
        , infoText = "Změny by měly provádět pouze oprávněné osoby."
        , informAdviceText = "Zvažte, jestli byste neměli o změnách uvědomit hlasující."
        }
    , create =
        { newProjectHeader = "Nový projekt"
        , infoText = "Projekt obsahuje jedno či více hlasování různých typů."
        , addPollFirstPart = "Přidat "
        , addPollBoldPart = "hlasování"
        , addPollLastPart = " pro: "
        , pollDescriptionGeneric = "Když se rozhoduje o\u{00A0}tom CO, KDO, KAM nebo KDE."
        , pollDescriptionDate = "Když se rozhoduje o\u{00A0}tom KDY."
        , projectCreatedText = "Hurá. Projekt byl vytvořen. Tento odkaz si zkopírujte a pošlete všem hlasujícím!"
        , projectCreatedInfo1 = "Odkaz obsahuje dešifrovací klíč. Pokud o něj přijdete, nebudete moci k hlasování přistupovat."
        , projectCreatedInfo2 = "Na server se posílají pouze zašifrovaná data. Bez dešifrovacího klíče jsou bezcenná. Tak ho neztraťte ;-)"
        , createProjectWithNPolls = \n -> "Vytvořit projekt (" ++ String.fromInt n ++ " hlasování)"
        }
    , pollEditor =
        { removePoll = "Odstranit hlasování"
        , editorTitleDate = \i -> "Hlasování " ++ String.fromInt i ++ ": Datum"
        , editorTitleGeneric = \i -> "Hlasování " ++ String.fromInt i ++ ": Obecné"
        , pollTitlePlaceholderDate = "např. Kdy se sejdeme?"
        , pollTitlePlaceholderGeneric = "např. Co za dárek? nebo Jaká hospoda?"
        , pollDescriptionPlaceholder = "Sem můžete napsat podrobnější informace o hlasování, ale nemusíte."
        , optionsInstructionsGeneric = "Zadejte možnosti, o kterých se bude hlasovat."
        , optionsInstructionsDate = "Označte v kalendáři termíny, o kterých se bude hlasovat."
        , addOption = "Přidat možnost"
        , hide = "Skrýt"
        , unhide = "Odkrýt"
        , hiddenSuffix = " (skryté)"
        , optionsOverview = "Přehled možností:"
        , nothingSelected = "nic nevybráno :-("
        }
    }
