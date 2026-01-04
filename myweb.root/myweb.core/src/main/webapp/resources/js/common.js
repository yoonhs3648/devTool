//region Common ajax 설정
// 1. 공통 AJAX 설정
/* 사용예시
$.ajax({
    url: "/dev/test",
    type: "GET",
    contentType: "application/json;charset=UTF-8",
    dataType: 'json'
    async: false,
    success: function(res){
        // 성공 처리
        console.log(res.message)
    },
    error: function(response, status, error){
        // 실패 처리
    }
});
*/
$.ajaxSetup({
    contentType: 'application/json; charset=UTF-8',
    dataType: 'text',
    async: true
});

// 1-1 공통 Ajax 콜백처리
$.ajaxPrefilter(function (options, originalOptions, jqXHR) {
    const origSuccess = options.success;
    const origError = options.error;

    options.success = function (response, status, xhr) {
        defaultAjaxSuccessHandler(response, status, xhr);   //솔루션내 공통 성공 처리
        if (typeof origSuccess === "function") {
            origSuccess(response, status, xhr);  //기존 핸들러 호출
        }
    };

    options.error = function (xhr, status, error) {
        defaultAjaxErrorHandler(xhr, status, error);  //솔루션내 공통 실패 처리
        if (typeof origError === "function") {
            origError(xhr, status, error);  //기존 핸들러 호출
        }
    };
});


// 1-2 공통 성공 처리 (예외처리돼서 성공으로 반환된 값 처리를 위한 재정의)
function defaultAjaxSuccessHandler(response, status, xhr) {
    const contentType = xhr.getResponseHeader("Content-Type") || "";

    // 서버에서 <script> 응답 시 스크립트 실행
    if (contentType.includes("text/html") && /<script[\s\S]*?>[\s\S]*?<\/script>/gi.test(response)) {
        try {
            const container = document.createElement('div');
            container.innerHTML = response;
            const scripts = container.querySelectorAll('script');
            scripts.forEach(script => eval(script.innerText));
        } catch (e) {
            //예외처리의 예외가 발생했을경우
            handleExceptionFallback("fail to handle exception handling", location.href, e.stack || e.toString());
        }
    } else {
        // 일반적으로 성공하는 경우
        // 여기에 로직을 작성해서는 안된다
    }
}

// 1-3 공통 예외 처리
function defaultAjaxErrorHandler(xhr, status, error) {
    let message = "알 수 없는 오류가 발생했습니다";
    let url = location.href;
    let trace = "";

    if (xhr && xhr.responseText) {
        const contentType = xhr.getResponseHeader("Content-Type") || "";

        // 서버에서 <script> 응답 시 스크립트 실행
        if (contentType.includes("text/html") && /<script[\s\S]*?>[\s\S]*?<\/script>/gi.test(xhr.responseText)) {
            try {
                const container = document.createElement('div');
                container.innerHTML = xhr.responseText;
                const scripts = container.querySelectorAll('script');
                scripts.forEach(script => eval(script.innerText));
                return;
            } catch (e) {
                message = "오류 스크립트 실행 실패";
                trace = e.stack || e.toString();
            }
        } else {
            message = xhr.responseText;
            trace = `${status} ${error}\n\n${xhr.responseText}`;
        }
    }

    handleExceptionFallback(message, url, trace);
}
//endregion

//region Common fetch 설정 (myFetch)
/* 사용예시
myFetch("/dev/test", {
    method: "GET",
    headers: {
        "Content-Type": "application/json;charset=UTF-8"
    },
}).then(res => { // 성공 처리. res는 json문자열
    res.json()  //json파싱
}).then(data => {
    console.log(data.message)
}).catch(error => {
    // 실패 처리
});
*/
function myFetch(input, init = {}) {
    // 기본 설정 병합
    const defaultHeaders = {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Requested-With': 'XMLHttpRequest'
    };

    // GET일 경우 body 제거
    if ((init.method || 'GET').toUpperCase() === 'GET') {
        delete init.body;
    }

    // 실제 fetch 호출
    return fetch(input, {
        ...init,
        headers: {
            ...defaultHeaders,
            ...(init.headers || {})
        }
    })
        .then(async (response) => {
            const contentType = response.headers.get("Content-Type") || "";
            const text = await response.text();

            if (response.ok) {
                // 서버에서 <script> 응답 시 스크립트 실행
                if (contentType.includes("text/html") && /<script[\s\S]*?>[\s\S]*?<\/script>/gi.test(text)) {
                    try {
                        const container = document.createElement('div');
                        container.innerHTML = text;
                        const scripts = container.querySelectorAll('script');
                        scripts.forEach(script => eval(script.innerText));
                    } catch (e) {
                        handleExceptionFallback("fail to handle exception handling", location.href, e.stack || e.toString());
                    }
                }
                return text; // 필요 시 JSON.parse(text) 가능
            } else {
                // 실패 응답 처리
                let message = "알 수 없는 오류가 발생했습니다.";
                let trace = "";

                if (contentType.includes("text/html") && /<script[\s\S]*?>[\s\S]*?<\/script>/gi.test(text)) {
                    try {
                        const container = document.createElement('div');
                        container.innerHTML = text;
                        const scripts = container.querySelectorAll('script');
                        scripts.forEach(script => eval(script.innerText));
                        return;
                    } catch (e) {
                        message = "오류 스크립트 실행 실패";
                        trace = e.stack || e.toString();
                    }
                } else {
                    message = text;
                    trace = `${response.status} ${response.statusText}\n\n${text}`;
                }

                handleExceptionFallback(message, location.href, trace);
                throw new Error(message);
            }
        })
        .catch((err) => {
            // 네트워크 오류 또는 위에서 throw한 경우
            const trace = err.stack || err.toString();
            handleExceptionFallback("fetch 요청 실패", location.href, trace);
            throw err; // 재전파
        });
}
//endregion

//region Common axios 설정
/* 사용예시
//get방식: axios.get(url, config) 형식으로 작성

    //요청 (쿼리스트링으로 데이터 전송, Content-Type 없음)
    myAxios.get('/api/test', {
      headers: {
        'Authorization': 'Bearer your-token' // 인증 토큰 등 헤더 설정
      },
      params: {
        userId: 123,       // 자동으로 /api/test?userId=123&active=true 형태로 변환됨
        active: true
      }
    })
    .then(res => {
        //응답이 일반 String일때
        const result = res.data; // 예: "Hello, world!"
        console.log("String 응답:", result);

        //응답이 배열일때(Array/List/Set)
        const list = res.data; // 예: ["apple", "banana", "grape"]
        list.forEach((item, index) => {
            console.log(`Item ${index}: ${item}`);
        });

        //응답이 Map일때(객체형태)
        const map = res.data; // 예: { name: "홍길동", age: 30, email: "test@example.com" }
        for (const key in map) {
            console.log(`${key} : ${map[key]}`);
        }

        // 또는 Object.entries 사용
        Object.entries(map).forEach(([key, value]) => {
            console.log(`${key}: ${value}`);
        });

    })
    .catch(error => {
      console.error('에러 발생:', error);
    });

    //서버 방식 1: HttpServletRequest로 받는 경우
    @RequestMapping(value = "/api/test", method = RequestMethod.GET)
    public ModelAndView goPage(HttpServletRequest request) {
        String userId = request.getParameter("userId");
        String active = request.getParameter("active");
        ...
    }

    //서버 방식 2: @RequestParam으로 받는 경우
    @RequestMapping(value = "/api/test", method = RequestMethod.GET)
    public @ResponseBody Map<String, Object> getUser(@RequestParam int userId, @RequestParam boolean active) {
        ...
    }


//post방식: axios.post(url, JSON-data, config) 형식으로 작성

    //요청 (Content-Type: application/json)
    myAxios.post('/api/test',
      {
        userId: 123,
        name: '홍길동'
      },
      {
        beforeSend: function () {
            showSpinner("요청 직후 실행되는 로직...");
        },
        complete: function () {
            alert("응답 직후 성공응답, 실패응답, 네트워크에러, 서버스크립트에러 모두 실행되는 로직");
        }
      }
    )
    .then(res => {
      const data = res.data;   // ← 핵심

      console.log(data.message);      //"처리 완료"
      console.log(data.data.name);    //"홍길동"
    })
    .catch(error => {
      const response = error.response;
      const status   = response ? response.status : null;
      const errMsg   = error.message;

      $("#parsedJson").html(`<div class='error'>오류 발생: [${status}] ${errMsg}</div>`);
    })
    .finally(() => {
      hideSpinner();
    });

    //서버
    @RequestMapping(value = "/api/test", method = RequestMethod.POST)
    public @ResponseBody Map<String, Object> postJson(@RequestBody Map<String, Object> payload) {
        String userId = String.valueOf(payload.get("userId"));
        String name = (String) payload.get("name");

        ObjectMapper mapper = new ObjectMapper();
        List<MyList> targetList = mapper.convertValue(requestBody.get("targetList"), new TypeReference<List<MyList>>() {})
        List<String> sourceList = mapper.convertValue(requestBody.get("sourceList"), List.class);
        List<String> sourceList = mapper.convertValue(requestBody.get("sourceList"), new TypeReference<List<String>>() {});   //제네릭 안정성 보장
        ...
    }


//post방식: axios.post(url, urlencoded-data, config) 형식으로 작성

    //요청 (Content-Type: application/x-www-form-urlencoded)
    const params = new URLSearchParams();
    params.append('userId', 123);
    params.append('name', '홍길동');

    axios.post('/api/test', params, {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    });

    //서버
    @RequestMapping(value = "/api/test", method = RequestMethod.POST)
    public @ResponseBody Map<String, Object> postForm(HttpServletRequest request) {
        String userId = request.getParameter("userId");
        String name = request.getParameter("name");
        ...
    }


//post방식: axios.post(url, multipart/form-data, config) 형식으로 작성

    //요청 (Content-Type: multipart/form-data)
    const formData = new FormData();
    formData.append('file', fileInput.files[0]);
    formData.append('userId', 123);

    axios.post('/api/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });

    //서버
    @RequestMapping(value = "/api/upload", method = RequestMethod.POST)
    public @ResponseBody String upload(@RequestParam("file") MultipartFile file,
                                       @RequestParam("userId") int userId) {
        ...
    }


//put방식: axios.put(url, JSON-data, config) 형식으로 작성

    //요청 (Content-Type: application/json)
    axios.put('/api/user/123',
      {
        name: '홍길동'
      },
      {
        headers: {
          'Content-Type': 'application/json'
        }
      }
    );

    //서버
    @RequestMapping(value = "/api/user/{id}", method = RequestMethod.PUT)
    public @ResponseBody Map<String, Object> updateUser(@PathVariable int id,
                                                        @RequestBody Map<String, Object> payload) {
        String name = String.valueOf(payload.get("name"));
        ...
    }
*/

/*
beforeSend()  // request interceptor
   ↓
[서버 응답]
   ↓
complete()    // response interceptor
   ↓
.then()
   ↓
.finally()
 */

//공통 axios 인스턴스 생성
const myAxios = axios.create({
    //baseURL: '',  //모든 요청에 붙는 기본 경로. myAxios.get('/user')는 실제로 [baseURL값]/user 요청이 됨
    //timeout: 10000, //10초 타임아웃. 요청이 이 시간(ms)을 초과하면 자동으로 요청을 취소하고 에러 발생
    headers: {  //요청마다 자동으로 포함되는 HTTP 헤더
        'X-Requested-With': 'XMLHttpRequest'    //서버가 이 요청이 AJAX인지 구분할 수 있게 해줌
    }
});

//요청 인터셉터: 모든 요청 전에 실행됨 (나중에 필요시 확장)
myAxios.interceptors.request.use(
    function (config) {
        //이 함수에서 config.headers, config.data, config.method 등을 수정 가능
        // 예시: config.headers['Authorization'] = 'Bearer my-token';

        //beforeSend : 요청 직후 요청진행중에 관한 작업
        if (typeof config.beforeSend === 'function') {
            config.beforeSend();
        }

        return config;
    },
    function (error) {
        // 요청 보내기 전 오류 발생 시
        return Promise.reject(error);   //인터셉터 안에서 문제가 발생했을 때 Promise.reject(error)를 하면 myAxios를 호출하는 .catch()로 바로 전달
    }
);

// 응답 인터셉터: 모든 응답 후 실행됨(공통 에러 처리, 스크립트 응답 실행)
myAxios.interceptors.response.use(
    function (response) {
        // complete : 성공응답을 받은 직후 작업
        if (response.config && typeof response.config.complete === 'function') {
            response.config.complete();
        }

        const contentType = response.headers['content-type'] || '';
        const text = typeof response.data === 'string' ? response.data : JSON.stringify(response.data);

        if (contentType.includes('text/html') && /<script[\s\S]*?>[\s\S]*?<\/script>/gi.test(text)) {
            try {
                const container = document.createElement('div');
                container.innerHTML = text;
                const scripts = container.querySelectorAll('script');
                scripts.forEach(script => eval(script.innerText));
            } catch (e) {
                handleExceptionFallback("fail to handle exception handling", location.href, e.stack || e.toString());
            }
        }

        return response;
    },
    function (error) {
        // complete : 실패응답 또는  네트워크에러, 서버스크립트에러 등을 받은 직후 작업
        if (error.config && typeof error.config.complete === 'function') {
            error.config.complete();
        }

        let message = "알 수 없는 오류가 발생했습니다.";
        let trace = "";
        const response = error.response;

        if (response) {
            const contentType = response.headers['content-type'] || '';
            const text = typeof response.data === 'string' ? response.data : JSON.stringify(response.data);

            if (contentType.includes('text/html') && /<script[\s\S]*?>[\s\S]*?<\/script>/gi.test(text)) {
                try {
                    const container = document.createElement('div');
                    container.innerHTML = text;
                    const scripts = container.querySelectorAll('script');
                    scripts.forEach(script => eval(script.innerText));
                    return Promise.reject(error); // 계속 catch로 전달
                } catch (e) {
                    message = "오류 스크립트 실행 실패";
                    trace = e.stack || e.toString();
                }
            } else {
                message = text;
                trace = `${response.status} ${response.statusText}\n\n${text}`;
            }
        } else {
            trace = error.stack || error.toString();
        }

        handleExceptionFallback(message, location.href, trace);
        return Promise.reject(error); // catch에서 받을 수 있도록
    }
);
//endregion

//region 공통 예외정보 모달 처리
function handleExceptionFallback(message, url, trace) {
    const data = {
        msg: message,
        url: url,
        trace: trace
    };

    fetch('/core/errorPopup', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    })
        .then(res => res.text())
        .then(html => {
            showModal(html); // 서버에서 받은 JSP 모달 HTML 표시
        })
        .catch(err => {
            console.error("예외 모달 표시 실패:", err);
            alert(message);  // 최후의 fallback
        });
}
//endregion