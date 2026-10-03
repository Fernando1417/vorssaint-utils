// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

struct DockProfileStrings {
    let title: String
    let description: String
    let settingsHint: String
    let empty: String
    let openSettings: String
    let apply: String
    let restartHint: String
    let inDock: String
    let undo: String
    let appliedFormat: String
    let restored: String
    let missingFormat: String
    let duplicateFormat: String
    let notWritten: String
    let notRestarted: String
    let newFromDock: String
    let newEmpty: String
    let defaultName: String
    let name: String
    let addApp: String
    let remove: String
    let moveLeft: String
    let moveRight: String
    let delete: String
    let noApps: String
    let notInstalled: String

    func applied(_ name: String) -> String { String(format: appliedFormat, name) }

    func message(_ outcome: DockProfileOutcome) -> String {
        switch outcome {
        case .applied(let name): return applied(name)
        case .restored: return restored
        case .notWritten: return notWritten
        case .notRestarted: return notRestarted
        case .problem(let problem):
            var lines: [String] = []
            if !problem.missing.isEmpty {
                lines.append(String(format: missingFormat, problem.missing.map(\.displayName).joined(separator: ", ")))
            }
            if !problem.duplicates.isEmpty {
                let names = Set(problem.duplicates.map(\.displayName)).sorted()
                lines.append(String(format: duplicateFormat, names.joined(separator: ", ")))
            }
            return lines.joined(separator: " ")
        }
    }
}

extension FeatureStrings {
    static func dockProfiles(_ language: AppLanguage) -> DockProfileStrings {
        switch language {
        case .enUS: return DockProfileStrings(
            title: "Dock Profiles",
            description: "Save sets of Dock apps and switch the Dock between them from Settings or the Dynamic Island.",
            settingsHint: "Each profile is a set of app icons for the Dock, left to right. Finder always stays first, and folders, files and Dock settings like size and position stay as they are.",
            empty: "No Dock profiles yet. Create one in Settings.",
            openSettings: "Open Settings",
            apply: "Apply",
            restartHint: "Applying restarts the Dock, so it disappears for a moment.",
            inDock: "In the Dock",
            undo: "Undo Last Change",
            appliedFormat: "%@ is now in the Dock.",
            restored: "The Dock is back as it was.",
            missingFormat: "Not installed anymore: %@. Remove them from the profile or reinstall them.",
            duplicateFormat: "Listed more than once: %@.",
            notWritten: "The Dock’s preferences did not save. Nothing changed.",
            notRestarted: "The Dock’s apps changed, but the Dock did not restart to show them. Log out and back in to see them.",
            newFromDock: "New from Current Dock",
            newEmpty: "New Empty Profile",
            defaultName: "Profile",
            name: "Name",
            addApp: "Add App…",
            remove: "Remove",
            moveLeft: "Move Left",
            moveRight: "Move Right",
            delete: "Delete Profile",
            noApps: "No apps yet. Add some, then drag them into order.",
            notInstalled: "Not installed"
        )
        case .ptBR: return DockProfileStrings(
            title: "Perfis do Dock",
            description: "Salve conjuntos de apps do Dock e troque o Dock entre eles pelos Ajustes ou pela Dynamic Island.",
            settingsHint: "Cada perfil é um conjunto de ícones de apps para o Dock, da esquerda para a direita. O Finder fica sempre primeiro, e pastas, arquivos e ajustes do Dock como tamanho e posição continuam como estão.",
            empty: "Ainda não há perfis do Dock. Crie um nos Ajustes.",
            openSettings: "Abrir Ajustes",
            apply: "Aplicar",
            restartHint: "Aplicar reinicia o Dock, que some por um instante.",
            inDock: "No Dock",
            undo: "Desfazer Última Alteração",
            appliedFormat: "%@ agora está no Dock.",
            restored: "O Dock voltou a ser como era.",
            missingFormat: "Não estão mais instalados: %@. Remova-os do perfil ou reinstale-os.",
            duplicateFormat: "Aparecem mais de uma vez: %@.",
            notWritten: "As preferências do Dock não foram salvas. Nada mudou.",
            notRestarted: "Os apps do Dock mudaram, mas o Dock não reiniciou para mostrá-los. Encerre a sessão e entre de novo para vê-los.",
            newFromDock: "Novo a Partir do Dock Atual",
            newEmpty: "Novo Perfil Vazio",
            defaultName: "Perfil",
            name: "Nome",
            addApp: "Adicionar App…",
            remove: "Remover",
            moveLeft: "Mover para a Esquerda",
            moveRight: "Mover para a Direita",
            delete: "Apagar Perfil",
            noApps: "Ainda não há apps. Adicione alguns e arraste-os na ordem desejada.",
            notInstalled: "Não instalado"
        )
        case .es: return DockProfileStrings(
            title: "Perfiles del Dock",
            description: "Guarda conjuntos de apps del Dock y cambia el Dock entre ellos desde Ajustes o la Dynamic Island.",
            settingsHint: "Cada perfil es un conjunto de iconos de apps para el Dock, de izquierda a derecha. Finder siempre va primero, y las carpetas, los archivos y los ajustes del Dock como el tamaño y la posición se quedan como están.",
            empty: "Aún no hay perfiles del Dock. Crea uno en Ajustes.",
            openSettings: "Abrir Ajustes",
            apply: "Aplicar",
            restartHint: "Al aplicar se reinicia el Dock, que desaparece un momento.",
            inDock: "En el Dock",
            undo: "Deshacer Último Cambio",
            appliedFormat: "%@ ya está en el Dock.",
            restored: "El Dock ha vuelto a como estaba.",
            missingFormat: "Ya no están instaladas: %@. Quítalas del perfil o vuelve a instalarlas.",
            duplicateFormat: "Aparecen más de una vez: %@.",
            notWritten: "Las preferencias del Dock no se guardaron. No ha cambiado nada.",
            notRestarted: "Las apps del Dock cambiaron, pero el Dock no se reinició para mostrarlas. Cierra sesión y vuelve a entrar para verlas.",
            newFromDock: "Nuevo a Partir del Dock Actual",
            newEmpty: "Nuevo Perfil Vacío",
            defaultName: "Perfil",
            name: "Nombre",
            addApp: "Añadir App…",
            remove: "Quitar",
            moveLeft: "Mover a la Izquierda",
            moveRight: "Mover a la Derecha",
            delete: "Eliminar Perfil",
            noApps: "Aún no hay apps. Añade algunas y arrástralas para ordenarlas.",
            notInstalled: "No instalada"
        )
        case .sk: return DockProfileStrings(
            title: "Profily Docku",
            description: "Uložte si sady aplikácií v Docku a prepínajte medzi nimi v Nastaveniach alebo v Dynamic Island.",
            settingsHint: "Každý profil je sada ikon aplikácií pre Dock zľava doprava. Finder zostáva vždy prvý a priečinky, súbory a nastavenia Docku ako veľkosť a poloha zostávajú bez zmeny.",
            empty: "Zatiaľ nemáte žiadne profily Docku. Vytvorte si ho v Nastaveniach.",
            openSettings: "Otvoriť Nastavenia",
            apply: "Použiť",
            restartHint: "Použitie reštartuje Dock, ktorý na chvíľu zmizne.",
            inDock: "V Docku",
            undo: "Vrátiť poslednú zmenu",
            appliedFormat: "%@ je teraz v Docku.",
            restored: "Dock je znova taký, aký bol.",
            missingFormat: "Už nie sú nainštalované: %@. Odstráňte ich z profilu alebo ich znova nainštalujte.",
            duplicateFormat: "Uvedené viackrát: %@.",
            notWritten: "Nastavenia Docku sa neuložili. Nič sa nezmenilo.",
            notRestarted: "Aplikácie v Docku sa zmenili, ale Dock sa nereštartoval, aby ich ukázal. Odhláste sa a znova sa prihláste.",
            newFromDock: "Nový z aktuálneho Docku",
            newEmpty: "Nový prázdny profil",
            defaultName: "Profil",
            name: "Názov",
            addApp: "Pridať aplikáciu…",
            remove: "Odstrániť",
            moveLeft: "Posunúť doľava",
            moveRight: "Posunúť doprava",
            delete: "Vymazať profil",
            noApps: "Zatiaľ žiadne aplikácie. Pridajte ich a potom ich presuňte do poradia.",
            notInstalled: "Nie je nainštalovaná"
        )
        case .de: return DockProfileStrings(
            title: "Dock-Profile",
            description: "Sichere Sätze von Dock-Apps und wechsle das Dock in den Einstellungen oder in der Dynamic Island zwischen ihnen.",
            settingsHint: "Jedes Profil ist ein Satz von App-Symbolen für das Dock, von links nach rechts. Der Finder bleibt immer vorn, und Ordner, Dateien und Dock-Einstellungen wie Größe und Position bleiben, wie sie sind.",
            empty: "Noch keine Dock-Profile. Erstelle eines in den Einstellungen.",
            openSettings: "Einstellungen öffnen",
            apply: "Anwenden",
            restartHint: "Beim Anwenden startet das Dock neu und verschwindet kurz.",
            inDock: "Im Dock",
            undo: "Letzte Änderung widerrufen",
            appliedFormat: "%@ ist jetzt im Dock.",
            restored: "Das Dock ist wieder wie vorher.",
            missingFormat: "Nicht mehr installiert: %@. Entferne sie aus dem Profil oder installiere sie erneut.",
            duplicateFormat: "Mehrfach aufgeführt: %@.",
            notWritten: "Die Dock-Einstellungen wurden nicht gesichert. Nichts wurde geändert.",
            notRestarted: "Die Apps im Dock wurden geändert, aber das Dock hat nicht neu gestartet, um sie zu zeigen. Melde dich ab und wieder an, um sie zu sehen.",
            newFromDock: "Neu aus aktuellem Dock",
            newEmpty: "Neues leeres Profil",
            defaultName: "Profil",
            name: "Name",
            addApp: "App hinzufügen …",
            remove: "Entfernen",
            moveLeft: "Nach links",
            moveRight: "Nach rechts",
            delete: "Profil löschen",
            noApps: "Noch keine Apps. Füge welche hinzu und ziehe sie in die gewünschte Reihenfolge.",
            notInstalled: "Nicht installiert"
        )
        case .fr: return DockProfileStrings(
            title: "Profils du Dock",
            description: "Enregistrez des ensembles d’apps du Dock et basculez le Dock de l’un à l’autre depuis les Réglages ou la Dynamic Island.",
            settingsHint: "Chaque profil est un ensemble d’icônes d’apps pour le Dock, de gauche à droite. Le Finder reste toujours en premier, et les dossiers, les fichiers et les réglages du Dock comme la taille et la position restent tels quels.",
            empty: "Aucun profil du Dock pour l’instant. Créez-en un dans les Réglages.",
            openSettings: "Ouvrir les Réglages",
            apply: "Appliquer",
            restartHint: "Appliquer redémarre le Dock, qui disparaît un instant.",
            inDock: "Dans le Dock",
            undo: "Annuler la dernière modification",
            appliedFormat: "%@ est maintenant dans le Dock.",
            restored: "Le Dock est revenu comme avant.",
            missingFormat: "Ne sont plus installées : %@. Retirez-les du profil ou réinstallez-les.",
            duplicateFormat: "Présentes plusieurs fois : %@.",
            notWritten: "Les préférences du Dock n’ont pas été enregistrées. Rien n’a changé.",
            notRestarted: "Les apps du Dock ont changé, mais le Dock n’a pas redémarré pour les afficher. Fermez la session puis rouvrez-la pour les voir.",
            newFromDock: "Nouveau à partir du Dock actuel",
            newEmpty: "Nouveau profil vide",
            defaultName: "Profil",
            name: "Nom",
            addApp: "Ajouter une app…",
            remove: "Retirer",
            moveLeft: "Déplacer à gauche",
            moveRight: "Déplacer à droite",
            delete: "Supprimer le profil",
            noApps: "Aucune app pour l’instant. Ajoutez-en, puis faites-les glisser dans l’ordre voulu.",
            notInstalled: "Non installée"
        )
        case .it: return DockProfileStrings(
            title: "Profili del Dock",
            description: "Salva gruppi di app del Dock e passa dall’uno all’altro da Impostazioni o dalla Dynamic Island.",
            settingsHint: "Ogni profilo è un gruppo di icone di app per il Dock, da sinistra a destra. Il Finder resta sempre per primo, e cartelle, file e impostazioni del Dock come dimensione e posizione restano come sono.",
            empty: "Ancora nessun profilo del Dock. Creane uno in Impostazioni.",
            openSettings: "Apri Impostazioni",
            apply: "Applica",
            restartHint: "Applicare riavvia il Dock, che scompare per un attimo.",
            inDock: "Nel Dock",
            undo: "Annulla ultima modifica",
            appliedFormat: "%@ ora è nel Dock.",
            restored: "Il Dock è tornato com’era.",
            missingFormat: "Non più installate: %@. Rimuovile dal profilo o reinstallale.",
            duplicateFormat: "Presenti più di una volta: %@.",
            notWritten: "Le preferenze del Dock non sono state salvate. Non è cambiato nulla.",
            notRestarted: "Le app del Dock sono cambiate, ma il Dock non si è riavviato per mostrarle. Esci e rientra nella sessione per vederle.",
            newFromDock: "Nuovo dal Dock attuale",
            newEmpty: "Nuovo profilo vuoto",
            defaultName: "Profilo",
            name: "Nome",
            addApp: "Aggiungi app…",
            remove: "Rimuovi",
            moveLeft: "Sposta a sinistra",
            moveRight: "Sposta a destra",
            delete: "Elimina profilo",
            noApps: "Ancora nessuna app. Aggiungine qualcuna e trascinale nell’ordine voluto.",
            notInstalled: "Non installata"
        )
        case .ru: return DockProfileStrings(
            title: "Профили Dock",
            description: "Сохраняйте наборы приложений Dock и переключайте Dock между ними в Настройках или в Dynamic Island.",
            settingsHint: "Каждый профиль это набор значков приложений для Dock слева направо. Finder всегда остаётся первым, а папки, файлы и настройки Dock, например размер и положение, не меняются.",
            empty: "Профилей Dock пока нет. Создайте профиль в Настройках.",
            openSettings: "Открыть Настройки",
            apply: "Применить",
            restartHint: "При применении Dock перезапускается и на мгновение исчезает.",
            inDock: "В Dock",
            undo: "Отменить последнее изменение",
            appliedFormat: "%@ теперь в Dock.",
            restored: "Dock снова такой, каким был.",
            missingFormat: "Больше не установлены: %@. Удалите их из профиля или установите заново.",
            duplicateFormat: "Указаны несколько раз: %@.",
            notWritten: "Настройки Dock не сохранились. Ничего не изменилось.",
            notRestarted: "Приложения в Dock изменились, но Dock не перезапустился, чтобы их показать. Выйдите из системы и войдите снова.",
            newFromDock: "Новый из текущего Dock",
            newEmpty: "Новый пустой профиль",
            defaultName: "Профиль",
            name: "Название",
            addApp: "Добавить приложение…",
            remove: "Удалить",
            moveLeft: "Переместить влево",
            moveRight: "Переместить вправо",
            delete: "Удалить профиль",
            noApps: "Приложений пока нет. Добавьте их и перетащите в нужном порядке.",
            notInstalled: "Не установлено"
        )
        case .tr: return DockProfileStrings(
            title: "Dock Profilleri",
            description: "Dock uygulama setlerini kaydedin ve Dock’u Ayarlar’dan veya Dynamic Island’dan bunlar arasında değiştirin.",
            settingsHint: "Her profil, Dock için soldan sağa bir uygulama simgesi setidir. Finder her zaman ilk sırada kalır; klasörler, dosyalar ve boyut ile konum gibi Dock ayarları olduğu gibi kalır.",
            empty: "Henüz Dock profili yok. Ayarlar’da bir tane oluşturun.",
            openSettings: "Ayarlar’ı Aç",
            apply: "Uygula",
            restartHint: "Uygulamak Dock’u yeniden başlatır, Dock bir an kaybolur.",
            inDock: "Dock’ta",
            undo: "Son Değişikliği Geri Al",
            appliedFormat: "%@ artık Dock’ta.",
            restored: "Dock eski hâline döndü.",
            missingFormat: "Artık yüklü değil: %@. Bunları profilden kaldırın veya yeniden yükleyin.",
            duplicateFormat: "Birden fazla kez listelenmiş: %@.",
            notWritten: "Dock tercihleri kaydedilmedi. Hiçbir şey değişmedi.",
            notRestarted: "Dock uygulamaları değişti ama Dock bunları göstermek için yeniden başlamadı. Görmek için oturumu kapatıp yeniden açın.",
            newFromDock: "Mevcut Dock’tan Yeni",
            newEmpty: "Yeni Boş Profil",
            defaultName: "Profil",
            name: "Ad",
            addApp: "Uygulama Ekle…",
            remove: "Kaldır",
            moveLeft: "Sola Taşı",
            moveRight: "Sağa Taşı",
            delete: "Profili Sil",
            noApps: "Henüz uygulama yok. Birkaç tane ekleyin, sonra sürükleyerek sıralayın.",
            notInstalled: "Yüklü değil"
        )
        case .ja: return DockProfileStrings(
            title: "Dockプロファイル",
            description: "Dockのアプリのセットを保存し、設定やDynamic IslandからDockを切り替えます。",
            settingsHint: "各プロファイルは、Dockに左から右へ並べるアプリアイコンのセットです。Finderは常に先頭のままで、フォルダ、ファイル、サイズや位置などのDockの設定は変わりません。",
            empty: "Dockプロファイルはまだありません。設定で作成してください。",
            openSettings: "設定を開く",
            apply: "適用",
            restartHint: "適用するとDockが再起動し、一瞬消えます。",
            inDock: "Dockに表示中",
            undo: "最後の変更を取り消す",
            appliedFormat: "%@をDockに適用しました。",
            restored: "Dockを元に戻しました。",
            missingFormat: "インストールされていません: %@。プロファイルから削除するか、再インストールしてください。",
            duplicateFormat: "重複しています: %@。",
            notWritten: "Dockの環境設定を保存できませんでした。何も変更されていません。",
            notRestarted: "Dockのアプリは変更されましたが、Dockが再起動しませんでした。ログアウトしてもう一度ログインすると表示されます。",
            newFromDock: "現在のDockから新規作成",
            newEmpty: "空のプロファイルを新規作成",
            defaultName: "プロファイル",
            name: "名前",
            addApp: "アプリを追加…",
            remove: "削除",
            moveLeft: "左へ移動",
            moveRight: "右へ移動",
            delete: "プロファイルを削除",
            noApps: "アプリはまだありません。追加してからドラッグで並べ替えてください。",
            notInstalled: "インストールされていません"
        )
        case .ko: return DockProfileStrings(
            title: "Dock 프로필",
            description: "Dock 앱 세트를 저장하고 설정이나 Dynamic Island에서 Dock을 전환합니다.",
            settingsHint: "각 프로필은 Dock에 왼쪽부터 오른쪽으로 놓을 앱 아이콘 세트입니다. Finder는 항상 맨 앞에 있고, 폴더, 파일 및 크기와 위치 같은 Dock 설정은 그대로 유지됩니다.",
            empty: "아직 Dock 프로필이 없습니다. 설정에서 만드십시오.",
            openSettings: "설정 열기",
            apply: "적용",
            restartHint: "적용하면 Dock이 재시작되어 잠시 사라집니다.",
            inDock: "Dock에 표시 중",
            undo: "마지막 변경 취소",
            appliedFormat: "%@ 프로필이 Dock에 적용되었습니다.",
            restored: "Dock이 이전 상태로 돌아갔습니다.",
            missingFormat: "더 이상 설치되어 있지 않음: %@. 프로필에서 제거하거나 다시 설치하십시오.",
            duplicateFormat: "두 번 이상 추가됨: %@.",
            notWritten: "Dock 환경설정이 저장되지 않았습니다. 아무것도 변경되지 않았습니다.",
            notRestarted: "Dock 앱은 변경되었지만 Dock이 재시작되지 않았습니다. 로그아웃한 다음 다시 로그인하면 표시됩니다.",
            newFromDock: "현재 Dock으로 새로 만들기",
            newEmpty: "빈 프로필 새로 만들기",
            defaultName: "프로필",
            name: "이름",
            addApp: "앱 추가…",
            remove: "제거",
            moveLeft: "왼쪽으로 이동",
            moveRight: "오른쪽으로 이동",
            delete: "프로필 삭제",
            noApps: "아직 앱이 없습니다. 앱을 추가한 다음 드래그하여 순서를 정하십시오.",
            notInstalled: "설치되지 않음"
        )
        case .uk: return DockProfileStrings(
            title: "Профілі Dock",
            description: "Зберігайте набори програм Dock і перемикайте Dock між ними в Параметрах або в Dynamic Island.",
            settingsHint: "Кожен профіль є набором значків програм для Dock зліва направо. Finder завжди лишається першим, а папки, файли та параметри Dock, як-от розмір і положення, не змінюються.",
            empty: "Профілів Dock ще немає. Створіть профіль у Параметрах.",
            openSettings: "Відкрити Параметри",
            apply: "Застосувати",
            restartHint: "Під час застосування Dock перезапускається й на мить зникає.",
            inDock: "У Dock",
            undo: "Скасувати останню зміну",
            appliedFormat: "%@ тепер у Dock.",
            restored: "Dock знову такий, яким був.",
            missingFormat: "Більше не встановлені: %@. Вилучіть їх із профілю або встановіть знову.",
            duplicateFormat: "Указані кілька разів: %@.",
            notWritten: "Параметри Dock не збереглися. Нічого не змінилося.",
            notRestarted: "Програми в Dock змінилися, але Dock не перезапустився, щоб їх показати. Вийдіть із системи й увійдіть знову.",
            newFromDock: "Новий із поточного Dock",
            newEmpty: "Новий порожній профіль",
            defaultName: "Профіль",
            name: "Назва",
            addApp: "Додати програму…",
            remove: "Вилучити",
            moveLeft: "Перемістити ліворуч",
            moveRight: "Перемістити праворуч",
            delete: "Видалити профіль",
            noApps: "Програм ще немає. Додайте їх і перетягніть у потрібному порядку.",
            notInstalled: "Не встановлено"
        )
        case .zhHans: return DockProfileStrings(
            title: "程序坞描述文件",
            description: "存储多组程序坞 App，并在设置或灵动岛中切换程序坞。",
            settingsHint: "每个描述文件都是一组从左到右排列的程序坞 App 图标。访达始终排在最前，文件夹、文件以及大小和位置等程序坞设置保持不变。",
            empty: "还没有程序坞描述文件。请在设置中创建。",
            openSettings: "打开设置",
            apply: "应用",
            restartHint: "应用时程序坞会重新启动，短暂消失。",
            inDock: "在程序坞中",
            undo: "撤销上次更改",
            appliedFormat: "已将“%@”应用到程序坞。",
            restored: "程序坞已恢复原样。",
            missingFormat: "已不再安装：%@。请将其从描述文件中移除或重新安装。",
            duplicateFormat: "重复列出：%@。",
            notWritten: "程序坞偏好设置未存储，未做任何更改。",
            notRestarted: "程序坞 App 已更改，但程序坞未重新启动来显示它们。请注销后重新登录。",
            newFromDock: "从当前程序坞新建",
            newEmpty: "新建空描述文件",
            defaultName: "描述文件",
            name: "名称",
            addApp: "添加 App…",
            remove: "移除",
            moveLeft: "向左移动",
            moveRight: "向右移动",
            delete: "删除描述文件",
            noApps: "还没有 App。添加一些，然后拖移调整顺序。",
            notInstalled: "未安装"
        )
        case .zhTW: return DockProfileStrings(
            title: "Dock 設定檔",
            description: "儲存多組 Dock App，並從設定或動態島切換 Dock。",
            settingsHint: "每個設定檔都是一組由左到右排列的 Dock App 圖像。Finder 永遠排在最前面，檔案夾、檔案以及大小和位置等 Dock 設定都會保持不變。",
            empty: "尚無 Dock 設定檔。請在設定中建立。",
            openSettings: "打開設定",
            apply: "套用",
            restartHint: "套用時 Dock 會重新啟動，短暫消失。",
            inDock: "在 Dock 中",
            undo: "還原上次更改",
            appliedFormat: "已將「%@」套用到 Dock。",
            restored: "Dock 已恢復原狀。",
            missingFormat: "已不再安裝：%@。請將其從設定檔中移除或重新安裝。",
            duplicateFormat: "重複列出：%@。",
            notWritten: "Dock 偏好設定未儲存，沒有任何更改。",
            notRestarted: "Dock App 已更改，但 Dock 沒有重新啟動來顯示。請登出後重新登入。",
            newFromDock: "從目前 Dock 新增",
            newEmpty: "新增空白設定檔",
            defaultName: "設定檔",
            name: "名稱",
            addApp: "加入 App…",
            remove: "移除",
            moveLeft: "向左移動",
            moveRight: "向右移動",
            delete: "刪除設定檔",
            noApps: "尚無 App。加入一些後，拖移來調整順序。",
            notInstalled: "未安裝"
        )
        case .zhHK: return DockProfileStrings(
            title: "Dock 設定檔",
            description: "儲存多組 Dock App，並從設定或動態島切換 Dock。",
            settingsHint: "每個設定檔都是一組由左至右排列的 Dock App 圖像。Finder 永遠排在最前面，檔案夾、檔案以及大小和位置等 Dock 設定都會保持不變。",
            empty: "尚未有 Dock 設定檔。請在設定中建立。",
            openSettings: "打開設定",
            apply: "套用",
            restartHint: "套用時 Dock 會重新啟動，短暫消失。",
            inDock: "在 Dock 中",
            undo: "還原上次更改",
            appliedFormat: "已將「%@」套用至 Dock。",
            restored: "Dock 已回復原狀。",
            missingFormat: "已不再安裝：%@。請將其從設定檔中移除或重新安裝。",
            duplicateFormat: "重複列出：%@。",
            notWritten: "Dock 偏好設定未儲存，沒有任何更改。",
            notRestarted: "Dock App 已更改，但 Dock 未有重新啟動來顯示。請登出後重新登入。",
            newFromDock: "從目前 Dock 新增",
            newEmpty: "新增空白設定檔",
            defaultName: "設定檔",
            name: "名稱",
            addApp: "加入 App…",
            remove: "移除",
            moveLeft: "向左移動",
            moveRight: "向右移動",
            delete: "刪除設定檔",
            noApps: "尚未有 App。加入一些後，拖移以調整次序。",
            notInstalled: "未安裝"
        )
        }
    }
}
