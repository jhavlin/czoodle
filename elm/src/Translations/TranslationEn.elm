module Translations.TranslationEn exposing (translationEn)

import Translations.Translation exposing (Translation)


translationEn : Translation
translationEn =
    { code = "EN"
    , name = "Controls in English"
    , common =
        { projectTitleLabel = "Title:"
        , projectTitlePlaceholder = "e.g. Teambuilding, gift for aunt, or reunion of ballet dancers"
        , pollTypeGeneric = "General"
        , pollTypeDate = "Date"
        , pollTitleLabel = "Name:"
        , pollDescriptionLabel = "Description:"
        , pollOptionsLabel = "Options:"
        , untitled = "(no name)"
        , waitPlease = "Wait, please."
        , remove = "Remove"
        , today = "Today"
        , monthNames = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ]
        , dayNamesShort = [ "Mo", "Tu", "We", "Th", "Fr", "Sa", "Su" ]
        , error = "Error"
        , saveChanges = "Save changes"
        , cancel = "Cancel"
        }
    , vote =
        { loading = "Loading"
        , saving = "Saving"
        , editProjectTitle = "Edit project (Authorized personnel only!)"
        , legend = "Legend"
        , yes = "Yes"
        , no = "No"
        , ifNeeded = "If needed"
        , poll = "Poll"
        , revertRowButtonTitle = "Revert changes in this row."
        , editRowButtonTitle = "Edit this row. Please remember that changing votes of others without consent is not nice!"
        , rowForDeletion = "To be deleted."
        , rowActionRevert = "Revert"
        , rowActionDelete = "Delete"
        , rowActionDeleteTitle = "Delete this row in this poll"
        , addRow = "+ Add person"
        , addRowTitle = "Add another person to all polls"
        , clearEmptyRows = "Clear empty rows"
        , clearEmptyRowsTitle = "Remove all rows with no entered name from all polls"
        , enterName = "Enter name!"
        , newPerson = "(new person)"
        }
    , editProject =
        { scrollDownButtonTitle = "Scroll down and save or cancel"
        , switchBackButtonTitle = "Switch back to voting"
        , infoText = "Only authorized personnel should edit project definition."
        , informAdviceText = "Consider informing voters about the changes."
        }
    , create =
        { newProjectHeader = "New Project"
        , infoText = "A project contains one or more polls of various types."
        , addPollFirstPart = "Add "
        , addPollBoldPart = "poll"
        , addPollLastPart = " for: "
        , pollDescriptionGeneric = "To decide a\u{00A0}question about WHAT, WHO, HOW or WHERE."
        , pollDescriptionDate = "To decide a\u{00A0}question about WHEN."
        , projectCreatedText = "Congratulations. Your project has been created. Please distribute the link below to the people that should vote."
        , projectCreatedInfo1 = "The link contains a decryption key. If you loose it, you won't be able to access your project."
        , projectCreatedInfo2 = "Only encrypted data are sent to the server. Without decryption key, they are pretty useless. So keep the link in a safe place ;-)"
        , createProjectWithNPolls = \n -> "Create project (" ++ String.fromInt n ++ " polls)"
        }
    , pollEditor =
        { removePoll = "Remove poll"
        , editorTitleDate = \i -> "Poll " ++ String.fromInt i ++ ": Date"
        , editorTitleGeneric = \i -> "Poll " ++ String.fromInt i ++ ": General"
        , pollTitlePlaceholderDate = "e.g. When will we meet?"
        , pollTitlePlaceholderGeneric = "e.g. What gift? or Which pub?"
        , pollDescriptionPlaceholder = "Here you can enter more detailed information about the poll if you want."
        , optionsInstructionsGeneric = "Enter list of available options."
        , optionsInstructionsDate = "Mark available options in the calendar."
        , addOption = "Add option"
        , hide = "Hide"
        , unhide = "Unhide"
        , hiddenSuffix = " (hidden)"
        , optionsOverview = "Overview of options:"
        , nothingSelected = "nothing selected :-("
        }
    }
