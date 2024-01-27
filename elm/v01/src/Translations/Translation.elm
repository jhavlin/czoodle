module Translations.Translation exposing (Translation)


type alias Translation =
    { code : String
    , name : String
    , common :
        { projectTitleLabel : String
        , projectTitlePlaceholder : String
        , pollTypeGeneric : String
        , pollTypeDate : String
        , pollTitleLabel : String
        , pollDescriptionLabel : String
        , pollOptionsLabel : String
        , untitled : String
        , waitPlease : String
        , remove : String
        , today : String
        , monthNames : List String
        , dayNamesShort : List String
        , error : String
        , saveChanges : String
        , cancel : String
        }
    , vote :
        { loading : String
        , saving : String
        , editProjectTitle : String
        , legend : String
        , yes : String
        , no : String
        , ifNeeded : String
        , poll : String
        , revertRowButtonTitle : String
        , editRowButtonTitle : String
        , rowForDeletion : String
        , rowActionRevert : String
        , rowActionDelete : String
        , rowActionDeleteTitle : String
        , addRow : String
        , addRowTitle : String
        , clearEmptyRows : String
        , clearEmptyRowsTitle : String
        , enterName : String
        , newPerson : String
        }
    , editProject :
        { scrollDownButtonTitle : String
        , switchBackButtonTitle : String
        , infoText : String
        , informAdviceText : String
        }
    , create :
        { newProjectHeader : String
        , infoText : String
        , addPollFirstPart : String
        , addPollBoldPart : String
        , addPollLastPart : String
        , pollDescriptionGeneric : String
        , pollDescriptionDate : String
        , projectCreatedText : String
        , projectCreatedInfo1 : String
        , projectCreatedInfo2 : String
        , createProjectWithNPolls : Int -> String
        }
    , pollEditor :
        { removePoll : String
        , editorTitleDate : Int -> String
        , editorTitleGeneric : Int -> String
        , pollTitlePlaceholderDate : String
        , pollTitlePlaceholderGeneric : String
        , pollDescriptionPlaceholder : String
        , optionsInstructionsGeneric : String
        , optionsInstructionsDate : String
        , addOption : String
        , hide : String
        , unhide : String
        , hiddenSuffix : String
        , optionsOverview : String
        , nothingSelected : String
        }
    }
