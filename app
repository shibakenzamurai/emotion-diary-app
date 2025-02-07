<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>感情分析日記アプリ</title>
  <!-- Tailwind CSS CDN -->
  <script src="https://cdn.tailwindcss.com"></script>
  <!-- Chart.js CDN -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="bg-gray-100">

  <!-- ★ ログイン画面 ★ -->
  <div id="loginPage" class="flex items-center justify-center min-h-screen p-4">
    <div class="bg-white p-8 rounded shadow-md w-full max-w-sm text-center">
      <h1 class="text-3xl font-bold mb-4">感情分析日記アプリ</h1>
      <p class="mb-6">ユーザーを選択してください</p>
      <!-- 各ユーザーボタン内にキャラクターアイコンを表示（かなれいのみ） -->
      <div class="flex flex-col gap-4">
        <button class="bg-blue-500 hover:bg-blue-600 text-white py-2 rounded" onclick="login('ともき')">
          ともき
        </button>
        <button class="bg-pink-500 hover:bg-pink-600 text-white py-2 rounded flex items-center justify-center gap-2" onclick="login('かなれい')">
          <img src="https://cdn.discordapp.com/attachments/1162299993038803074/1337437947842265118/E372E041-CF6C-4946-B0E6-F3C52099B6D2.png?ex=67a771a7&is=67a62027&hm=c553d26695afade285be8ec5502426464b231d2aaaf7588a3aed36096f9c4f5d" alt="かなれい Icon" class="w-6 h-6">
          かなれい
        </button>
      </div>
    </div>
  </div>

  <!-- ★ メイン画面 ★ -->
  <div id="mainPage" class="hidden">
    <!-- ヘッダー -->
    <header class="bg-white shadow p-4 flex justify-between items-center">
      <div class="flex items-center space-x-3">
        <!-- ヘッダーキャラクターアイコン（削除済み） -->
        <h1 class="text-2xl font-bold">感情分析日記アプリ</h1>
      </div>
      <div class="flex items-center space-x-4">
        <div id="userDisplay" class="text-lg"></div>
        <button onclick="logout()" class="bg-red-500 hover:bg-red-600 text-white py-1 px-3 rounded">ログアウト</button>
      </div>
    </header>
    <!-- コンテンツ -->
    <div class="container mx-auto p-4 space-y-8">
      <!-- 記録入力エリア -->
      <div class="bg-white p-6 rounded shadow">
        <h2 class="text-xl font-semibold mb-4">日記を入力</h2>
        <!-- カレンダー形式の記録日 -->
        <div class="mb-4">
          <label for="recordDate" class="mr-2 font-semibold">記録日：</label>
          <input id="recordDate" type="date" class="border border-gray-300 rounded p-1 w-full" value="">
        </div>
        <textarea id="diaryText" class="w-full border border-gray-300 rounded p-2" rows="4" placeholder="今日の出来事や気分を記録してください..."></textarea>
        <div class="mt-4 flex flex-wrap items-center gap-4">
          <button id="voiceBtn" class="bg-green-500 hover:bg-green-600 text-white py-2 px-4 rounded">音声入力</button>
          <button id="saveBtn" class="bg-blue-500 hover:bg-blue-600 text-white py-2 px-4 rounded">保存</button>
          <!-- 入力エリア内のキャラクター画像は削除済み -->
        </div>
        <!-- 保存直後のアドバイス表示 -->
        <div id="advice" class="mt-4 text-sm text-gray-700"></div>
      </div>

      <!-- グラフ表示エリア（平均感情スコア：-10～10） -->
      <div class="bg-white p-6 rounded shadow">
        <h2 class="text-xl font-semibold mb-4">感情スコアグラフ</h2>
        <canvas id="emotionChart" class="w-full" height="200"></canvas>
      </div>

      <!-- 日記履歴表示エリア -->
      <div class="bg-white p-6 rounded shadow">
        <h2 class="text-xl font-semibold mb-4">日記履歴</h2>
        <div id="diaryList" class="space-y-4"></div>
      </div>
    </div>
  </div>

  <!-- ★ 記録詳細＆アドバイス画面 ★ -->
  <div id="detailPage" class="hidden">
    <!-- ヘッダー -->
    <header class="bg-white shadow p-4 flex justify-between items-center">
      <div class="flex items-center space-x-3">
        <!-- 記録詳細ページのキャラクターアイコン（削除済み） -->
        <h1 class="text-2xl font-bold">記録詳細 &amp; アドバイス</h1>
      </div>
      <button onclick="backToMain()" class="bg-gray-500 hover:bg-gray-600 text-white py-1 px-3 rounded">戻る</button>
    </header>
    <div class="container mx-auto p-4">
      <div id="detailContent" class="bg-white p-6 rounded shadow space-y-4"></div>
    </div>
  </div>

  <!-- ★ JavaScript ★ -->
  <script>
    // グローバル変数
    let currentUser = null;
    // 各記録オブジェクト: { id, user, text, timestamp, recordDate, emotion, score }
    let diaryEntries = [];

    // ページ読み込み時：localStorage から記録を読み込み、カレンダーの初期値を今日に設定
    document.addEventListener('DOMContentLoaded', () => {
      const storedData = localStorage.getItem('diaryEntries');
      if (storedData) {
        diaryEntries = JSON.parse(storedData);
      }
      document.getElementById('recordDate').value = new Date().toISOString().split('T')[0];
      updateDiaryList();
      updateChart();
    });

    // ★ ユーザー認証 ★
    function login(user) {
      currentUser = user;
      document.getElementById('userDisplay').innerText = "ユーザー: " + currentUser;
      document.getElementById('loginPage').classList.add('hidden');
      document.getElementById('mainPage').classList.remove('hidden');
      document.getElementById('detailPage').classList.add('hidden');
      updateDiaryList();
      updateChart();
    }

    function logout() {
      currentUser = null;
      document.getElementById('loginPage').classList.remove('hidden');
      document.getElementById('mainPage').classList.add('hidden');
      document.getElementById('detailPage').classList.add('hidden');
    }

    function backToMain() {
      document.getElementById('detailPage').classList.add('hidden');
      document.getElementById('mainPage').classList.remove('hidden');
      updateDiaryList();
      updateChart();
    }

    // ★ 音声入力（Web Speech API） ★
    const voiceBtn = document.getElementById('voiceBtn');
    const diaryText = document.getElementById('diaryText');
    let recognition;
    if ('webkitSpeechRecognition' in window) {
      recognition = new webkitSpeechRecognition();
      recognition.lang = 'ja-JP';
      recognition.continuous = false;
      recognition.interimResults = false;
      recognition.onresult = function(event) {
        diaryText.value += event.results[0][0].transcript;
      }
    } else {
      voiceBtn.disabled = true;
      voiceBtn.innerText = "音声入力未対応";
    }
    voiceBtn.addEventListener('click', () => {
      if (recognition) recognition.start();
    });

    // ★ 記録の保存 ★
    document.getElementById('saveBtn').addEventListener('click', async () => {
      const text = diaryText.value.trim();
      if (text === "") {
        alert("日記を入力してください");
        return;
      }
      const recordDate = document.getElementById('recordDate').value;
      
      // o3mini の API を利用した高度な感情解析（非同期処理）
      let analysis;
      try {
        analysis = await analyzeEmotion(text);
      } catch (error) {
        console.error("o3mini API 呼び出しエラー:", error);
        // エラー時はローカル解析でフォールバック
        analysis = localAnalyzeEmotion(text);
      }
      
      const entry = {
        id: Date.now(),
        user: currentUser,
        text: text,
        timestamp: new Date().toISOString(),
        recordDate: recordDate,
        emotion: analysis.emotion,
        score: analysis.score
      };
      diaryEntries.push(entry);
      localStorage.setItem('diaryEntries', JSON.stringify(diaryEntries));
      diaryText.value = "";
      document.getElementById('advice').innerText = getLongAdvice(entry.emotion, entry.score, text);
      updateDiaryList();
      updateChart();
    });

    // ★ 高度な感情解析（o3mini API を利用） ★
    async function analyzeEmotion(text) {
      // ※ 以下は o3mini API の架空のエンドポイント例です。実際の仕様に合わせて変更してください。
      const response = await fetch('https://api.o3mini.example.com/analyze', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY'
        },
        body: JSON.stringify({ text: text })
      });
      if (!response.ok) {
        throw new Error('API エラー');
      }
      const data = await response.json();
      return data;
    }

    // フォールバック用：従来のローカル解析
    function localAnalyzeEmotion(text) {
      const positiveWords = [
        { word: "楽しい", weight: 3 },
        { word: "嬉しい", weight: 3 },
        { word: "幸せ", weight: 3 },
        { word: "希望", weight: 2 },
        { word: "安心", weight: 2 },
        { word: "穏やか", weight: 2 },
        { word: "感謝", weight: 2 },
        { word: "充実", weight: 2 }
      ];
      const negativeWords = [
        { word: "悲しい", weight: 3 },
        { word: "辛い", weight: 3 },
        { word: "苦しい", weight: 3 },
        { word: "絶望", weight: 3 },
        { word: "不安", weight: 3 },
        { word: "心配", weight: 2 },
        { word: "孤独", weight: 2 },
        { word: "疲れた", weight: 2 },
        { word: "落ち込む", weight: 3 },
        { word: "悩む", weight: 2 },
        { word: "苦悩", weight: 3 }
      ];
      let score = 0;
      positiveWords.forEach(item => {
        const count = text.split(item.word).length - 1;
        score += count * item.weight;
      });
      negativeWords.forEach(item => {
        const count = text.split(item.word).length - 1;
        score -= count * item.weight;
      });
      score = score * 1.5;
      if(score > 10) score = 10;
      if(score < -10) score = -10;
      let emotion = "ニュートラル";
      if (score > 2) emotion = "ポジティブ";
      else if (score < -2) emotion = "ネガティブ";
      return { emotion, score: Math.round(score) };
    }

    // ★ 長文アドバイス生成（カウンセラーとしての視点） ★
    function getLongAdvice(emotion, score, text) {
      let advice = "";
      if (emotion === "ポジティブ") {
        advice = "あなたが感じている喜びや希望は、まるで温かな太陽のようです。日々の小さな幸せを大切にし、そのエネルギーを周囲と分かち合ってください。あなたの感情スコアは " + score + " 点です。これからもその輝きを保ち続け、困難な時にも自分を信じて進んでいってください。";
      } else if (emotion === "ネガティブ") {
        advice = "あなたの記録からは、深い悲しみや不安、孤独が感じられます。どんなに心が重く感じられても、あなたは決して一人ではありません。信頼できる人に話を聞いてもらったり、専門家のサポートを受けたりすることで、少しずつ心が軽くなることを願っています。あなたの感情スコアは " + score + " 点です。どうか自分自身を大切にし、必要な時には助けを求めてください。";
      } else {
        advice = "あなたの記録は、バランスの取れた心の状態を示しています。どんな感情もあなたの一部です。今後も自分の気持ちに正直に向き合いながら、無理なく前進していってください。あなたの感情スコアは " + score + " 点です。日々の小さな前進が、明るい未来への一歩となるでしょう。";
      }
      return advice;
    }

    // ★ 記録一覧の更新 ★
    function updateDiaryList() {
      const diaryList = document.getElementById('diaryList');
      diaryList.innerHTML = "";
      if (!currentUser) return;
      const userEntries = diaryEntries.filter(entry => entry.user === currentUser);
      if (userEntries.length === 0) {
        diaryList.innerHTML = "<p class='text-gray-500'>まだ日記がありません。</p>";
        return;
      }
      // 最新順にソート
      userEntries.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
      userEntries.forEach(entry => {
        const entryDiv = document.createElement('div');
        entryDiv.classList.add('p-4', 'border', 'rounded', 'cursor-pointer', 'hover:bg-gray-100');
        const date = new Date(entry.timestamp);
        entryDiv.innerHTML = `
          <div class="flex justify-between items-center mb-2">
            <span class="text-sm text-gray-500">${date.toLocaleString()}</span>
            <span class="px-2 py-1 rounded bg-gray-200 text-sm">${entry.emotion} (${entry.score}点)</span>
          </div>
          <p>${entry.text.substring(0, 50)}${entry.text.length > 50 ? "..." : ""}</p>
        `;
        entryDiv.setAttribute('data-id', entry.id);
        entryDiv.addEventListener('click', () => { viewDiaryDetail(entry.id); });
        diaryList.appendChild(entryDiv);
      });
    }

    // ★ 記録詳細画面 ★
    function viewDiaryDetail(id) {
      const entry = diaryEntries.find(e => e.id == id);
      if (!entry) return;
      document.getElementById('mainPage').classList.add('hidden');
      document.getElementById('detailPage').classList.remove('hidden');
      
      const date = new Date(entry.timestamp);
      const detailContent = document.getElementById('detailContent');
      detailContent.innerHTML = `
        <div>
          <span class="text-sm text-gray-500">${date.toLocaleString()}</span>
          <span id="detailEmotionDisplay" class="px-2 py-1 rounded bg-gray-200 text-sm">${entry.emotion}</span>
          <span class="ml-2 text-sm text-gray-600">(スコア: <span id="detailScoreDisplay">${entry.score}</span>点)</span>
        </div>
        <p class="mb-4">${entry.text}</p>
        <div class="p-4 bg-blue-100 rounded">
          <strong>o3miniからのアドバイス:</strong>
          <p id="detailAdvice">${getLongAdvice(entry.emotion, entry.score, entry.text)}</p>
        </div>
        <!-- 感情変更セクション -->
        <div class="mt-4">
          <label for="emotionSelect" class="mr-2 font-semibold">感情変更:</label>
          <select id="emotionSelect" class="border border-gray-300 rounded p-1">
            <option value="ポジティブ">ポジティブ</option>
            <option value="ネガティブ">ネガティブ</option>
            <option value="ニュートラル">ニュートラル</option>
          </select>
          <button onclick="updateRecordEmotion(${entry.id})" class="ml-2 bg-yellow-500 hover:bg-yellow-600 text-white py-1 px-3 rounded">更新</button>
        </div>
        <!-- 感情スコア調整セクション -->
        <div class="mt-4">
          <label for="scoreSlider" class="mr-2 font-semibold">感情スコア調整 ( -10 ～ 10 ):</label>
          <input type="range" id="scoreSlider" min="-10" max="10" step="1" value="${entry.score}" oninput="document.getElementById('scoreValue').innerText = this.value">
          <span id="scoreValue">${entry.score}</span>
          <button onclick="updateRecordScore(${entry.id})" class="ml-2 bg-yellow-500 hover:bg-yellow-600 text-white py-1 px-3 rounded">更新</button>
        </div>
        <!-- 削除ボタン -->
        <div class="mt-4">
          <button onclick="deleteRecord(${entry.id})" class="bg-red-500 hover:bg-red-600 text-white py-1 px-3 rounded">この記録を削除</button>
        </div>
      `;
      document.getElementById('emotionSelect').value = entry.emotion;
    }

    // 感情ラベルの更新
    function updateRecordEmotion(id) {
      const selectElem = document.getElementById('emotionSelect');
      const newEmotion = selectElem.value;
      const entryIndex = diaryEntries.findIndex(e => e.id == id);
      if (entryIndex === -1) return;
      diaryEntries[entryIndex].emotion = newEmotion;
      localStorage.setItem('diaryEntries', JSON.stringify(diaryEntries));
      document.getElementById('detailEmotionDisplay').innerText = newEmotion;
      document.getElementById('detailAdvice').innerText = getLongAdvice(newEmotion, diaryEntries[entryIndex].score, diaryEntries[entryIndex].text);
      updateDiaryList();
      updateChart();
    }

    // 感情スコアの更新
    function updateRecordScore(id) {
      const scoreValue = parseInt(document.getElementById('scoreSlider').value, 10);
      const entryIndex = diaryEntries.findIndex(e => e.id == id);
      if (entryIndex === -1) return;
      diaryEntries[entryIndex].score = scoreValue;
      localStorage.setItem('diaryEntries', JSON.stringify(diaryEntries));
      document.getElementById('detailScoreDisplay').innerText = scoreValue;
      document.getElementById('detailAdvice').innerText = getLongAdvice(diaryEntries[entryIndex].emotion, scoreValue, diaryEntries[entryIndex].text);
      updateDiaryList();
      updateChart();
    }

    // 記録の削除
    function deleteRecord(id) {
      if (!confirm("この記録を削除してもよろしいですか？")) return;
      diaryEntries = diaryEntries.filter(e => e.id != id);
      localStorage.setItem('diaryEntries', JSON.stringify(diaryEntries));
      backToMain();
    }

    // ★ グラフ更新 ★
    let emotionChart;
    function updateChart() {
      if (!currentUser) return;
      const userEntries = diaryEntries.filter(entry => entry.user === currentUser);
      const dateMap = {};
      userEntries.forEach(entry => {
        const date = entry.recordDate;
        if (!dateMap[date]) { dateMap[date] = { sum: 0, count: 0 }; }
        dateMap[date].sum += entry.score;
        dateMap[date].count += 1;
      });
      const labels = Object.keys(dateMap).sort();
      const avgScores = labels.map(date => (dateMap[date].sum / dateMap[date].count).toFixed(2));
      
      const ctx = document.getElementById('emotionChart').getContext('2d');
      if (emotionChart) { emotionChart.destroy(); }
      emotionChart = new Chart(ctx, {
        type: 'line',
        data: {
          labels: labels,
          datasets: [{
            label: '平均感情スコア',
            data: avgScores,
            borderColor: 'blue',
            fill: false,
            tension: 0.2
          }]
        },
        options: {
          responsive: true,
          scales: {
            y: {
              min: -10,
              max: 10,
              title: { display: true, text: 'スコア (-10 ～ 10)' }
            }
          },
          plugins: {
            legend: { position: 'top' },
            title: { display: true, text: '日別平均感情スコア' }
          }
        }
      });
    }
  </script>
</body>
</html>
