// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

struct NotchKiwiDeskStrings {
    let title: String
    let description: String
    let loading: String
    let cliNotFound: String
    let serverUnreachable: String
    let cliError: String
    let noWindows: String
    let spaceFormat: String
    let switchFormat: String
    let layout: String
    let bringForward: String
    let makeFloating: String
    let makeTiled: String
    let toggleSticky: String
    let floating: String
    let focused: String
    let settingsHint: String
    let tool: String
    let toolMissing: String

    func space(_ id: String) -> String { String(format: spaceFormat, id) }
    func switchTo(_ id: String) -> String { String(format: switchFormat, id) }
}

extension FeatureStrings {
    static func notchKiwiDesk(_ language: AppLanguage) -> NotchKiwiDeskStrings {
        switch language {
        case .enUS: return NotchKiwiDeskStrings(
            title: "KiwiDesk",
            description: "The spaces of the KiwiDesk tiling window manager in the Dynamic Island: the apps on each one and the one in focus, with switching and layouts one click away.",
            loading: "Reading KiwiDesk…",
            cliNotFound: "The kiwidesk command line tool was not found. Install KiwiDesk with Homebrew, or add kiwidesk to your PATH.",
            serverUnreachable: "KiwiDesk is not running. Open it to see your spaces here.",
            cliError: "KiwiDesk did not answer as expected. Details are in Console under KiwiDesk.",
            noWindows: "No space has app windows.",
            spaceFormat: "Space %@",
            switchFormat: "Switch to Space %@",
            layout: "Layout",
            bringForward: "Bring Forward",
            makeFloating: "Make Floating",
            makeTiled: "Make Tiled",
            toggleSticky: "Show on All Spaces or One",
            floating: "Floating",
            focused: "In focus",
            settingsHint: "KiwiDesk is a separate app. Vorssaint reads it through the kiwidesk command line tool, only while this page is open.",
            tool: "Command line tool",
            toolMissing: "Not found"
        )
        case .ptBR: return NotchKiwiDeskStrings(
            title: "KiwiDesk",
            description: "As mesas do gerenciador de janelas em mosaico KiwiDesk na Dynamic Island: os apps de cada uma e o que está em foco, com troca e layouts a um clique.",
            loading: "Lendo o KiwiDesk…",
            cliNotFound: "A ferramenta de linha de comando kiwidesk não foi encontrada. Instale o KiwiDesk com o Homebrew ou adicione kiwidesk ao seu PATH.",
            serverUnreachable: "O KiwiDesk não está aberto. Abra-o para ver suas mesas aqui.",
            cliError: "O KiwiDesk não respondeu como esperado. Os detalhes estão no Console, em KiwiDesk.",
            noWindows: "Nenhuma mesa tem janelas de apps.",
            spaceFormat: "Mesa %@",
            switchFormat: "Ir para a Mesa %@",
            layout: "Layout",
            bringForward: "Trazer para a Frente",
            makeFloating: "Deixar Flutuante",
            makeTiled: "Deixar em Mosaico",
            toggleSticky: "Mostrar em Todas as Mesas ou em Uma",
            floating: "Flutuante",
            focused: "Em foco",
            settingsHint: "O KiwiDesk é um app à parte. O Vorssaint o lê pela ferramenta de linha de comando kiwidesk, só enquanto esta página está aberta.",
            tool: "Ferramenta de linha de comando",
            toolMissing: "Não encontrada"
        )
        case .es: return NotchKiwiDeskStrings(
            title: "KiwiDesk",
            description: "Los escritorios del gestor de ventanas en mosaico KiwiDesk en la Dynamic Island: las apps de cada uno y la que tiene el foco, con cambio y diseños a un clic.",
            loading: "Leyendo KiwiDesk…",
            cliNotFound: "No se encontró la herramienta de línea de comandos kiwidesk. Instala KiwiDesk con Homebrew o añade kiwidesk a tu PATH.",
            serverUnreachable: "KiwiDesk no está abierto. Ábrelo para ver tus escritorios aquí.",
            cliError: "KiwiDesk no respondió como se esperaba. Los detalles están en Consola, en KiwiDesk.",
            noWindows: "Ningún escritorio tiene ventanas de apps.",
            spaceFormat: "Escritorio %@",
            switchFormat: "Ir al Escritorio %@",
            layout: "Diseño",
            bringForward: "Traer al Frente",
            makeFloating: "Hacer Flotante",
            makeTiled: "Poner en Mosaico",
            toggleSticky: "Mostrar en Todos los Escritorios o en Uno",
            floating: "Flotante",
            focused: "Con el foco",
            settingsHint: "KiwiDesk es una app aparte. Vorssaint lo lee con la herramienta de línea de comandos kiwidesk, solo mientras esta página está abierta.",
            tool: "Herramienta de línea de comandos",
            toolMissing: "No encontrada"
        )
        case .sk: return NotchKiwiDeskStrings(
            title: "KiwiDesk",
            description: "Plochy dlaždicového správcu okien KiwiDesk v Dynamic Island: aplikácie na každej z nich a tá, ktorá je v popredí, s prepínaním a rozložením na jedno kliknutie.",
            loading: "Číta sa KiwiDesk…",
            cliNotFound: "Nástroj príkazového riadka kiwidesk sa nenašiel. Nainštalujte KiwiDesk cez Homebrew alebo pridajte kiwidesk do PATH.",
            serverUnreachable: "KiwiDesk nie je spustený. Otvorte ho a uvidíte tu svoje plochy.",
            cliError: "KiwiDesk neodpovedal podľa očakávania. Podrobnosti nájdete v Konzole pod KiwiDesk.",
            noWindows: "Žiadna plocha nemá okná aplikácií.",
            spaceFormat: "Plocha %@",
            switchFormat: "Prepnúť na plochu %@",
            layout: "Rozloženie",
            bringForward: "Preniesť dopredu",
            makeFloating: "Nechať plávať",
            makeTiled: "Usporiadať do dlaždíc",
            toggleSticky: "Zobraziť na všetkých plochách alebo na jednej",
            floating: "Plávajúce",
            focused: "V popredí",
            settingsHint: "KiwiDesk je samostatná aplikácia. Vorssaint ho číta cez nástroj príkazového riadka kiwidesk, iba kým je táto stránka otvorená.",
            tool: "Nástroj príkazového riadka",
            toolMissing: "Nenašiel sa"
        )
        case .de: return NotchKiwiDeskStrings(
            title: "KiwiDesk",
            description: "Die Schreibtische des Kachel-Fenstermanagers KiwiDesk in der Dynamic Island: die Apps auf jedem und die aktive, mit Wechsel und Layouts nur einen Klick entfernt.",
            loading: "KiwiDesk wird gelesen …",
            cliNotFound: "Das Befehlszeilenwerkzeug kiwidesk wurde nicht gefunden. Installiere KiwiDesk mit Homebrew oder füge kiwidesk zu deinem PATH hinzu.",
            serverUnreachable: "KiwiDesk läuft nicht. Öffne es, um deine Schreibtische hier zu sehen.",
            cliError: "KiwiDesk hat nicht wie erwartet geantwortet. Details stehen in der Konsole unter KiwiDesk.",
            noWindows: "Kein Schreibtisch hat App-Fenster.",
            spaceFormat: "Schreibtisch %@",
            switchFormat: "Zu Schreibtisch %@ wechseln",
            layout: "Layout",
            bringForward: "Nach vorne holen",
            makeFloating: "Schwebend machen",
            makeTiled: "Kacheln",
            toggleSticky: "Auf allen Schreibtischen oder einem zeigen",
            floating: "Schwebend",
            focused: "Aktiv",
            settingsHint: "KiwiDesk ist eine eigene App. Vorssaint liest es über das Befehlszeilenwerkzeug kiwidesk, nur solange diese Seite offen ist.",
            tool: "Befehlszeilenwerkzeug",
            toolMissing: "Nicht gefunden"
        )
        case .fr: return NotchKiwiDeskStrings(
            title: "KiwiDesk",
            description: "Les bureaux du gestionnaire de fenêtres en mosaïque KiwiDesk dans la Dynamic Island : les apps de chacun et celle au premier plan, avec le changement et les dispositions à un clic.",
            loading: "Lecture de KiwiDesk…",
            cliNotFound: "L’outil en ligne de commande kiwidesk est introuvable. Installez KiwiDesk avec Homebrew ou ajoutez kiwidesk à votre PATH.",
            serverUnreachable: "KiwiDesk n’est pas ouvert. Ouvrez-le pour voir vos bureaux ici.",
            cliError: "KiwiDesk n’a pas répondu comme prévu. Les détails sont dans Console, sous KiwiDesk.",
            noWindows: "Aucun bureau n’a de fenêtre d’app.",
            spaceFormat: "Bureau %@",
            switchFormat: "Aller au bureau %@",
            layout: "Disposition",
            bringForward: "Mettre au premier plan",
            makeFloating: "Rendre flottante",
            makeTiled: "Mettre en mosaïque",
            toggleSticky: "Afficher sur tous les bureaux ou un seul",
            floating: "Flottante",
            focused: "Au premier plan",
            settingsHint: "KiwiDesk est une app à part. Vorssaint le lit avec l’outil en ligne de commande kiwidesk, seulement pendant que cette page est ouverte.",
            tool: "Outil en ligne de commande",
            toolMissing: "Introuvable"
        )
        case .it: return NotchKiwiDeskStrings(
            title: "KiwiDesk",
            description: "Le scrivanie del gestore di finestre a riquadri KiwiDesk nella Dynamic Island: le app su ognuna e quella in primo piano, con cambio e layout a un clic.",
            loading: "Lettura di KiwiDesk…",
            cliNotFound: "Lo strumento da riga di comando kiwidesk non è stato trovato. Installa KiwiDesk con Homebrew o aggiungi kiwidesk al tuo PATH.",
            serverUnreachable: "KiwiDesk non è aperto. Aprilo per vedere qui le tue scrivanie.",
            cliError: "KiwiDesk non ha risposto come previsto. I dettagli sono in Console, sotto KiwiDesk.",
            noWindows: "Nessuna scrivania ha finestre di app.",
            spaceFormat: "Scrivania %@",
            switchFormat: "Vai alla Scrivania %@",
            layout: "Layout",
            bringForward: "Porta in primo piano",
            makeFloating: "Rendi mobile",
            makeTiled: "Affianca",
            toggleSticky: "Mostra su tutte le scrivanie o su una",
            floating: "Mobile",
            focused: "In primo piano",
            settingsHint: "KiwiDesk è un’app separata. Vorssaint lo legge con lo strumento da riga di comando kiwidesk, solo mentre questa pagina è aperta.",
            tool: "Strumento da riga di comando",
            toolMissing: "Non trovato"
        )
        case .ru: return NotchKiwiDeskStrings(
            title: "KiwiDesk",
            description: "Рабочие столы плиточного оконного менеджера KiwiDesk в Dynamic Island: приложения на каждом и активное, с переключением и раскладками в один клик.",
            loading: "Чтение KiwiDesk…",
            cliNotFound: "Инструмент командной строки kiwidesk не найден. Установите KiwiDesk через Homebrew или добавьте kiwidesk в PATH.",
            serverUnreachable: "KiwiDesk не запущен. Откройте его, чтобы видеть здесь свои рабочие столы.",
            cliError: "KiwiDesk ответил не так, как ожидалось. Подробности в Консоли, в разделе KiwiDesk.",
            noWindows: "Ни на одном рабочем столе нет окон приложений.",
            spaceFormat: "Рабочий стол %@",
            switchFormat: "Перейти на рабочий стол %@",
            layout: "Раскладка",
            bringForward: "На передний план",
            makeFloating: "Сделать плавающим",
            makeTiled: "Вернуть в плитку",
            toggleSticky: "Показывать на всех рабочих столах или одном",
            floating: "Плавающее",
            focused: "Активно",
            settingsHint: "KiwiDesk является отдельным приложением. Vorssaint читает его через инструмент командной строки kiwidesk, только пока эта страница открыта.",
            tool: "Инструмент командной строки",
            toolMissing: "Не найден"
        )
        case .tr: return NotchKiwiDeskStrings(
            title: "KiwiDesk",
            description: "KiwiDesk döşemeli pencere yöneticisinin masaüstleri Dynamic Island’da: her birindeki uygulamalar ve odaktaki, geçiş ve yerleşimler bir tık uzakta.",
            loading: "KiwiDesk okunuyor…",
            cliNotFound: "kiwidesk komut satırı aracı bulunamadı. KiwiDesk’i Homebrew ile yükleyin veya kiwidesk’i PATH’inize ekleyin.",
            serverUnreachable: "KiwiDesk çalışmıyor. Masaüstlerinizi burada görmek için açın.",
            cliError: "KiwiDesk beklendiği gibi yanıt vermedi. Ayrıntılar Konsol’da, KiwiDesk altında.",
            noWindows: "Hiçbir masaüstünde uygulama penceresi yok.",
            spaceFormat: "Masaüstü %@",
            switchFormat: "Masaüstüne geç: %@",
            layout: "Yerleşim",
            bringForward: "Öne Getir",
            makeFloating: "Yüzer Yap",
            makeTiled: "Döşe",
            toggleSticky: "Tüm Masaüstlerinde veya Birinde Göster",
            floating: "Yüzer",
            focused: "Odakta",
            settingsHint: "KiwiDesk ayrı bir uygulamadır. Vorssaint onu yalnızca bu sayfa açıkken kiwidesk komut satırı aracıyla okur.",
            tool: "Komut satırı aracı",
            toolMissing: "Bulunamadı"
        )
        case .ja: return NotchKiwiDeskStrings(
            title: "KiwiDesk",
            description: "タイル型ウインドウマネージャKiwiDeskのデスクトップをDynamic Islandに表示します。各デスクトップのアプリと操作中のアプリが分かり、切り替えやレイアウト変更もワンクリックです。",
            loading: "KiwiDeskを読み込み中…",
            cliNotFound: "kiwideskコマンドラインツールが見つかりません。HomebrewでKiwiDeskをインストールするか、kiwideskをPATHに追加してください。",
            serverUnreachable: "KiwiDeskが起動していません。起動するとここにデスクトップが表示されます。",
            cliError: "KiwiDeskから想定外の応答がありました。詳細はコンソールのKiwiDeskで確認できます。",
            noWindows: "アプリのウインドウがあるデスクトップはありません。",
            spaceFormat: "デスクトップ %@",
            switchFormat: "デスクトップ %@ に切り替える",
            layout: "レイアウト",
            bringForward: "手前に表示",
            makeFloating: "フローティングにする",
            makeTiled: "タイルに戻す",
            toggleSticky: "すべてのデスクトップに表示を切り替え",
            floating: "フローティング",
            focused: "操作中",
            settingsHint: "KiwiDeskは別のアプリです。Vorssaintはこのページが開いている間だけ、kiwideskコマンドラインツールを使って読み取ります。",
            tool: "コマンドラインツール",
            toolMissing: "見つかりません"
        )
        case .ko: return NotchKiwiDeskStrings(
            title: "KiwiDesk",
            description: "타일형 윈도우 관리자 KiwiDesk의 데스크탑을 Dynamic Island에서 보여 줍니다. 각 데스크탑의 앱과 현재 사용 중인 앱을 확인하고, 전환과 레이아웃 변경도 한 번의 클릭으로 할 수 있습니다.",
            loading: "KiwiDesk 읽는 중…",
            cliNotFound: "kiwidesk 명령줄 도구를 찾을 수 없습니다. Homebrew로 KiwiDesk를 설치하거나 kiwidesk를 PATH에 추가하십시오.",
            serverUnreachable: "KiwiDesk가 실행 중이 아닙니다. 실행하면 여기에서 데스크탑을 볼 수 있습니다.",
            cliError: "KiwiDesk가 예상과 다르게 응답했습니다. 자세한 내용은 콘솔의 KiwiDesk에서 확인하십시오.",
            noWindows: "앱 윈도우가 있는 데스크탑이 없습니다.",
            spaceFormat: "데스크탑 %@",
            switchFormat: "데스크탑 %@(으)로 전환",
            layout: "레이아웃",
            bringForward: "앞으로 가져오기",
            makeFloating: "떠 있게 만들기",
            makeTiled: "타일로 배치",
            toggleSticky: "모든 데스크탑에 표시 전환",
            floating: "떠 있음",
            focused: "사용 중",
            settingsHint: "KiwiDesk는 별도의 앱입니다. Vorssaint는 이 페이지가 열려 있는 동안에만 kiwidesk 명령줄 도구로 읽습니다.",
            tool: "명령줄 도구",
            toolMissing: "찾을 수 없음"
        )
        case .uk: return NotchKiwiDeskStrings(
            title: "KiwiDesk",
            description: "Робочі столи плиткового менеджера вікон KiwiDesk у Dynamic Island: програми на кожному й активна, з перемиканням і розкладками в один клік.",
            loading: "Читання KiwiDesk…",
            cliNotFound: "Інструмент командного рядка kiwidesk не знайдено. Установіть KiwiDesk через Homebrew або додайте kiwidesk до PATH.",
            serverUnreachable: "KiwiDesk не запущено. Відкрийте його, щоб бачити тут свої робочі столи.",
            cliError: "KiwiDesk відповів не так, як очікувалося. Подробиці в Консолі, у розділі KiwiDesk.",
            noWindows: "На жодному робочому столі немає вікон програм.",
            spaceFormat: "Робочий стіл %@",
            switchFormat: "Перейти на робочий стіл %@",
            layout: "Розкладка",
            bringForward: "На передній план",
            makeFloating: "Зробити плаваючим",
            makeTiled: "Повернути в плитку",
            toggleSticky: "Показувати на всіх робочих столах або одному",
            floating: "Плаваюче",
            focused: "Активне",
            settingsHint: "KiwiDesk є окремою програмою. Vorssaint читає її через інструмент командного рядка kiwidesk, лише поки ця сторінка відкрита.",
            tool: "Інструмент командного рядка",
            toolMissing: "Не знайдено"
        )
        case .zhHans: return NotchKiwiDeskStrings(
            title: "KiwiDesk",
            description: "在灵动岛中显示平铺窗口管理器 KiwiDesk 的桌面：每个桌面上的 App 和当前聚焦的 App，切换桌面和布局只需一次点按。",
            loading: "正在读取 KiwiDesk…",
            cliNotFound: "找不到 kiwidesk 命令行工具。请用 Homebrew 安装 KiwiDesk，或将 kiwidesk 添加到 PATH。",
            serverUnreachable: "KiwiDesk 未在运行。打开它即可在这里看到你的桌面。",
            cliError: "KiwiDesk 的回应不符合预期。详细信息在“控制台”的 KiwiDesk 下。",
            noWindows: "没有桌面包含 App 窗口。",
            spaceFormat: "桌面 %@",
            switchFormat: "切换到桌面 %@",
            layout: "布局",
            bringForward: "移到前面",
            makeFloating: "设为浮动",
            makeTiled: "设为平铺",
            toggleSticky: "切换在所有桌面上显示",
            floating: "浮动",
            focused: "已聚焦",
            settingsHint: "KiwiDesk 是一个独立的 App。Vorssaint 只在此页面打开时通过 kiwidesk 命令行工具读取它。",
            tool: "命令行工具",
            toolMissing: "未找到"
        )
        case .zhTW: return NotchKiwiDeskStrings(
            title: "KiwiDesk",
            description: "在動態島中顯示平鋪視窗管理器 KiwiDesk 的桌面：每個桌面上的 App 和目前聚焦的 App，切換桌面和佈局只需按一下。",
            loading: "正在讀取 KiwiDesk…",
            cliNotFound: "找不到 kiwidesk 命令列工具。請用 Homebrew 安裝 KiwiDesk，或將 kiwidesk 加入 PATH。",
            serverUnreachable: "KiwiDesk 未在執行。打開它即可在這裡看到你的桌面。",
            cliError: "KiwiDesk 的回應不如預期。詳細資訊在「主控台」的 KiwiDesk 類別下。",
            noWindows: "沒有桌面包含 App 視窗。",
            spaceFormat: "桌面 %@",
            switchFormat: "切換到桌面 %@",
            layout: "佈局",
            bringForward: "移到前面",
            makeFloating: "設為浮動",
            makeTiled: "設為平鋪",
            toggleSticky: "切換在所有桌面上顯示",
            floating: "浮動",
            focused: "已聚焦",
            settingsHint: "KiwiDesk 是一個獨立的 App。Vorssaint 只在此頁面開啟時透過 kiwidesk 命令列工具讀取它。",
            tool: "命令列工具",
            toolMissing: "找不到"
        )
        case .zhHK: return NotchKiwiDeskStrings(
            title: "KiwiDesk",
            description: "在動態島中顯示平鋪視窗管理器 KiwiDesk 的桌面：每個桌面上的 App 和目前聚焦的 App，切換桌面和佈局只需按一下。",
            loading: "正在讀取 KiwiDesk…",
            cliNotFound: "找不到 kiwidesk 命令列工具。請用 Homebrew 安裝 KiwiDesk，或將 kiwidesk 加入 PATH。",
            serverUnreachable: "KiwiDesk 未有執行。打開它即可在這裏看到你的桌面。",
            cliError: "KiwiDesk 的回應不如預期。詳細資料在「主控台」的 KiwiDesk 類別下。",
            noWindows: "沒有桌面包含 App 視窗。",
            spaceFormat: "桌面 %@",
            switchFormat: "切換到桌面 %@",
            layout: "佈局",
            bringForward: "移到前面",
            makeFloating: "設為浮動",
            makeTiled: "設為平鋪",
            toggleSticky: "切換在所有桌面上顯示",
            floating: "浮動",
            focused: "已聚焦",
            settingsHint: "KiwiDesk 是一個獨立的 App。Vorssaint 只在此頁面開啟時透過 kiwidesk 命令列工具讀取它。",
            tool: "命令列工具",
            toolMissing: "找不到"
        )
        }
    }
}
