# Real Time Streaming Protocol (RTSP)
> **RFC 2326 - Giao thức truyền phát thời gian thực (Real Time Streaming Protocol)**

| Thuộc tính | Giá trị |
| :--- | :--- |
| **Nhóm công tác** | Nhóm công tác mạng (Network Working Group) |
| **Yêu cầu bình luận (RFC)** | 2326 |
| **Phân loại** | Theo dõi tiêu chuẩn (Standards Track) |
| **Tác giả** | H. Schulzrinne (Columbia U.), A. Rao (Netscape), R. Lanphier (RealNetworks) |
| **Thời gian công bố** | Tháng 4 năm 1998 |

---

## Tình trạng của bản ghi nhớ (Status of this Memo)

Tài liệu này xác định một giao thức theo dõi tiêu chuẩn Internet cho cộng đồng Internet và kêu gọi thảo luận cũng như đóng góp ý kiến để cải tiến. Vui lòng tham khảo ấn bản hiện tại của "Internet Official Protocol Standards" (STD 1) để biết trạng thái và cấp độ tiêu chuẩn hóa của giao thức này. Việc phân phối bản ghi nhớ này là không giới hạn.

## Thông báo bản quyền (Copyright Notice)

Copyright (C) The Internet Society (1998). Mọi quyền được bảo lưu.

## Tóm tắt (Abstract)

Giao thức truyền phát thời gian thực (Real Time Streaming Protocol - RTSP) là một giao thức ở tầng ứng dụng nhằm điều khiển việc phân phối dữ liệu có các đặc tính thời gian thực. RTSP cung cấp một khuôn khổ có khả năng mở rộng để kích hoạt việc phân phối theo yêu cầu, có kiểm soát đối với dữ liệu thời gian thực như âm thanh và video. Các nguồn dữ liệu có thể bao gồm cả luồng trực tiếp (live feed) lẫn các đoạn clip đã được lưu trữ sẵn. Giao thức này nhằm mục đích điều khiển nhiều phiên phân phối dữ liệu, cung cấp phương tiện để lựa chọn các kênh phân phối như UDP, UDP đa hướng (multicast) và TCP, đồng thời cung cấp phương tiện để chọn các cơ chế phân phối dựa trên RTP (RFC 1889).

---

## Mục lục (Table of Contents)

- [1 Giới thiệu (Introduction)](#1-giới-thiệu-introduction)
  - [1.1 Mục đích (Purpose)](#11-mục-đích-purpose)
  - [1.2 Yêu cầu (Requirements)](#12-yêu-cầu-requirements)
  - [1.3 Thuật ngữ (Terminology)](#13-thuật-ngữ-terminology)
  - [1.4 Các đặc tính của giao thức (Protocol Properties)](#14-các-đặc-tính-của-giao-thức-protocol-properties)
  - [1.5 Mở rộng RTSP (Extending RTSP)](#15-mở-rộng-rtsp-extending-rtsp)
  - [1.6 Hoạt động tổng thể (Overall Operation)](#16-hoạt-động-tổng-thể-overall-operation)
  - [1.7 Các trạng thái của RTSP (RTSP States)](#17-các-trạng-thái-của-rtsp-rtsp-states)
  - [1.8 Mối quan hệ với các giao thức khác (Relationship with Other Protocols)](#18-mối-quan-hệ-với-các-giao-thức-khác-relationship-with-other-protocols)
- [2 Quy ước ký hiệu (Notational Conventions)](#2-quy-ước-ký-hiệu-notational-conventions)
- [3 Các tham số giao thức (Protocol Parameters)](#3-các-tham-số-giao-thức-protocol-parameters)
  - [3.1 Phiên bản RTSP (RTSP Version)](#31-phiên-bản-rtsp-rtsp-version)
  - [3.2 RTSP URL](#32-rtsp-url)
  - [3.3 Mã định danh hội nghị (Conference Identifiers)](#33-mã-định-danh-hội-nghị-conference-identifiers)
  - [3.4 Mã định danh phiên (Session Identifiers)](#34-mã-định-danh-phiên-session-identifiers)
  - [3.5 Dấu thời gian tương đối SMPTE (SMPTE Relative Timestamps)](#35-dấu-thời-gian-tương-đối-smpte-smpte-relative-timestamps)
  - [3.6 Thời gian phát bình thường (Normal Play Time - NPT)](#36-thời-gian-phát-bình-thường-normal-play-time---npt)
  - [3.7 Thời gian tuyệt đối (Absolute Time)](#37-thời-gian-tuyệt-đối-absolute-time)
  - [3.8 Thẻ tùy chọn (Option Tags)](#38-thẻ-tùy-chọn-option-tags)
    - [3.8.1 Đăng ký thẻ tùy chọn mới với IANA (Registering New Option Tags with IANA)](#381-đăng-ký-thẻ-tùy-chọn-mới-với-iana-registering-new-option-tags-with-iana)
- [4 Thông điệp RTSP (RTSP Message)](#4-thông-điệp-rtsp-rtsp-message)
  - [4.1 Các loại thông điệp (Message Types)](#41-các-loại-thông-điệp-message-types)
  - [4.2 Các tiêu đề thông điệp (Message Headers)](#42-các-tiêu-đề-thông-điệp-message-headers)
  - [4.3 Thân thông điệp (Message Body)](#43-thân-thông-điệp-message-body)
  - [4.4 Độ dài thông điệp (Message Length)](#44-độ-dài-thông-điệp-message-length)
- [5 Các trường tiêu đề chung (General Header Fields)](#5-các-trường-tiêu-đề-chung-general-header-fields)
- [6 Yêu cầu (Request)](#6-yêu-cầu-request)
  - [6.1 Dòng yêu cầu (Request Line)](#61-dòng-yêu-cầu-request-line)
  - [6.2 Các trường tiêu đề yêu cầu (Request Header Fields)](#62-các-trường-tiêu-đề-yêu-cầu-request-header-fields)
- [7 Phản hồi (Response)](#7-phản-hồi-response)
  - [7.1 Dòng trạng thái (Status-Line)](#71-dòng-trạng-thái-status-line)
    - [7.1.1 Mã trạng thái và Cụm từ giải thích (Status Code and Reason Phrase)](#711-mã-trạng-thái-và-cụm-từ-giải-thích-status-code-and-reason-phrase)
    - [7.1.2 Các trường tiêu đề phản hồi (Response Header Fields)](#712-các-trường-tiêu-đề-phản-hồi-response-header-fields)
- [8 Thực thể (Entity)](#8-thực-thể-entity)
  - [8.1 Các trường tiêu đề thực thể (Entity Header Fields)](#81-các-trường-tiêu-đề-thực-thể-entity-header-fields)
  - [8.2 Thân thực thể (Entity Body)](#82-thân-thực-thể-entity-body)
- [9 Các kết nối (Connections)](#9-các-kết-nối-connections)
  - [9.1 Pipelining (Kỹ thuật đường ống)](#91-pipelining-kỹ-thuật-đường-ống)
  - [9.2 Độ tin cậy và Xác nhận (Reliability and Acknowledgements)](#92-độ-tin-cậy-và-xác-nhận-reliability-and-acknowledgements)
- [10 Định nghĩa phương thức (Method Definitions)](#10-định-nghĩa-phương-thức-method-definitions)
  - [10.1 OPTIONS](#101-options)
  - [10.2 DESCRIBE](#102-describe)
  - [10.3 ANNOUNCE](#103-announce)
  - [10.4 SETUP](#104-setup)
  - [10.5 PLAY](#105-play)
  - [10.6 PAUSE](#106-pause)
  - [10.7 TEARDOWN](#107-teardown)
  - [10.8 GET_PARAMETER](#108-get-parameter)
  - [10.9 SET_PARAMETER](#109-set-parameter)
  - [10.10 REDIRECT](#1010-redirect)
  - [10.11 RECORD](#1011-record)
  - [10.12 Dữ liệu nhị phân nhúng (xen kẽ) - Embedded Binary Data](#1012-dữ-liệu-nhị-phân-nhúng-xen-kẽ---embedded-binary-data)
- [11 Định nghĩa mã trạng thái (Status Code Definitions)](#11-định-nghĩa-mã-trạng-thái-status-code-definitions)
  - [11.1 Thành công (Success) 2xx](#111-thành-công-success-2xx)
  - [11.2 Chuyển hướng (Redirection) 3xx](#112-chuyển-hướng-redirection-3xx)
  - [11.3 Lỗi máy khách (Client Error) 4xx](#113-lỗi-máy-khách-client-error-4xx)
- [12 Định nghĩa các trường tiêu đề (Header Field Definitions)](#12-định-nghĩa-các-trường-tiêu-đề-header-field-definitions)
  - [12.1 Accept](#121-accept)
  - [12.2 Accept-Encoding](#122-accept-encoding)
  - [12.3 Accept-Language](#123-accept-language)
  - [12.4 Allow](#124-allow)
  - [12.5 Authorization](#125-authorization)
  - [12.6 Bandwidth](#126-bandwidth)
  - [12.7 Blocksize](#127-blocksize)
  - [12.8 Cache-Control](#128-cache-control)
  - [12.9 Conference](#129-conference)
  - [12.10 Connection](#1210-connection)
  - [12.11 Content-Base](#1211-content-base)
  - [12.12 Content-Encoding](#1212-content-encoding)
  - [12.13 Content-Language](#1213-content-language)
  - [12.14 Content-Length](#1214-content-length)
  - [12.15 Content-Location](#1215-content-location)
  - [12.16 Content-Type](#1216-content-type)
  - [12.17 CSeq](#1217-cseq)
  - [12.18 Date](#1218-date)
  - [12.19 Expires](#1219-expires)
  - [12.20 From](#1220-from)
  - [12.21 Host](#1221-host)
  - [12.22 If-Match](#1222-if-match)
  - [12.23 If-Modified-Since](#1223-if-modified-since)
  - [12.24 Last-Modified](#1224-last-modified)
  - [12.25 Location](#1225-location)
  - [12.26 Proxy-Authenticate](#1226-proxy-authenticate)
  - [12.27 Proxy-Require](#1227-proxy-require)
  - [12.28 Public](#1228-public)
  - [12.29 Range](#1229-range)
  - [12.30 Referer](#1230-referer)
  - [12.31 Retry-After](#1231-retry-after)
  - [12.32 Require](#1232-require)
  - [12.33 RTP-Info](#1233-rtp-info)
  - [12.34 Scale](#1234-scale)
  - [12.35 Speed](#1235-speed)
  - [12.36 Server](#1236-server)
  - [12.37 Session](#1237-session)
  - [12.38 Timestamp](#1238-timestamp)
  - [12.39 Transport](#1239-transport)
  - [12.40 Unsupported](#1240-unsupported)
  - [12.41 User-Agent](#1241-user-agent)
  - [12.42 Vary](#1242-vary)
  - [12.43 Via](#1243-via)
  - [12.44 WWW-Authenticate](#1244-www-authenticate)
- [13 Lưu vào bộ nhớ đệm (Caching)](#13-lưu-vào-bộ-nhớ-đệm-caching)
- [14 Các ví dụ (Examples)](#14-các-ví-dụ-examples)
  - [14.1 Truyền thông theo yêu cầu (Unicast) - Media on Demand (Unicast)](#141-truyền-thông-theo-yêu-cầu-unicast---media-on-demand-unicast)
  - [14.2 Truyền phát tệp chứa (Container file) - Streaming of a Container File](#142-truyền-phát-tệp-chứa-container-file---streaming-of-a-container-file)
  - [14.3 Tệp chứa luồng đơn - Single Stream Container Files](#143-tệp-chứa-luồng-đơn---single-stream-container-files)
  - [14.4 Trình chiếu media trực tiếp dùng Multicast - Live Media Presentation Using Multicast](#144-trình-chiếu-media-trực-tiếp-dùng-multicast---live-media-presentation-using-multicast)
  - [14.5 Phát media vào một phiên hiện có - Playing Media into an Existing Session](#145-phát-media-vào-một-phiên-hiện-có---playing-media-into-an-existing-session)
  - [14.6 Ghi dữ liệu (Recording)](#146-ghi-dữ-liệu-recording)
- [15 Cú pháp (Syntax)](#15-cú-pháp-syntax)
  - [15.1 Cú pháp cơ sở (Base Syntax)](#151-cú-pháp-cơ-sở-base-syntax)
- [16 Các cân nhắc về bảo mật (Security Considerations)](#16-các-cân-nhắc-về-bảo-mật-security-considerations)
- [Phụ lục A: Máy trạng thái giao thức RTSP](#phụ-lục-a-máy-trạng-thái-giao-thức-rtsp)
  - [A.1 Máy trạng thái máy khách (Client State Machine)](#a1-máy-trạng-thái-máy-khách-client-state-machine)
  - [A.2 Máy trạng thái máy chủ (Server State Machine)](#a2-máy-trạng-thái-máy-chủ-server-state-machine)
- [Phụ lục B: Tương tác với RTP (Interaction with RTP)](#phụ-lục-b-tương-tác-với-rtp-interaction-with-rtp)
- [Phụ lục C: Sử dụng SDP cho mô tả phiên RTSP](#phụ-lục-c-sử-dụng-sdp-cho-mô-tả-phiên-rtsp)
  - [C.1 Các định nghĩa (Definitions)](#c1-các-định-nghĩa-definitions)
    - [C.1.1 URL điều khiển (Control URL)](#c11-url-điều-khiển-control-url)
    - [C.1.2 Các luồng phương tiện (Media streams)](#c12-các-luồng-phương-tiện-media-streams)
    - [C.1.3 (Các) kiểu tải trọng (Payload type(s))](#c13-các-kiểu-tải-trọng-payload-types)
    - [C.1.4 Các tham số riêng cho định dạng (Format-specific parameters)](#c14-các-tham-số-riêng-cho-định-dạng-format-specific-parameters)
    - [C.1.5 Khoảng giá trị của bản trình bày (Range of presentation)](#c15-khoảng-giá-trị-của-bản-trình-bày-range-of-presentation)
    - [C.1.6 Thời gian khả dụng (Time of availability)](#c16-thời-gian-khả-dụng-time-of-availability)
    - [C.1.7 Thông tin kết nối (Connection Information)](#c17-thông-tin-kết-nối-connection-information)
    - [C.1.8 Thẻ thực thể (Entity Tag)](#c18-thẻ-thực-thể-entity-tag)
  - [C.2 Không khả dụng điều khiển tổng hợp (Aggregate Control Not Available)](#c2-không-khả-dụng-điều-khiển-tổng-hợp-aggregate-control-not-available)
  - [C.3 Khả dụng điều khiển tổng hợp (Aggregate Control Available)](#c3-khả-dụng-điều-khiển-tổng-hợp-aggregate-control-available)
- [Phụ lục D: Triển khai RTSP tối thiểu (Minimal RTSP Implementation)](#phụ-lục-d-triển-khai-rtsp-tối-thiểu-minimal-rtsp-implementation)
  - [D.1 Máy khách (Client)](#d1-máy-khách-client)
    - [D.1.1 Phát lại cơ bản (Basic Playback)](#d11-phát-lại-cơ-bản-basic-playback)
    - [D.1.2 Đã kích hoạt xác thực (Authentication-enabled)](#d12-đã-kích-hoạt-xác-thực-authentication-enabled)
  - [D.2 Máy chủ (Server)](#d2-máy-chủ-server)
    - [D.2.1 Phát lại cơ bản (Basic Playback)](#d21-phát-lại-cơ-bản-basic-playback)
    - [D.2.2 Đã kích hoạt xác thực (Authentication-enabled)](#d22-đã-kích-hoạt-xác-thực-authentication-enabled)

---

## 1 Giới thiệu (Introduction)

### 1.1 Mục đích (Purpose)

Giao thức truyền phát thời gian thực (RTSP) thiết lập và kiểm soát
một hoặc nhiều luồng phương tiện liên tục được đồng bộ hóa theo thời
gian như âm thanh và video. Bản thân RTSP thường không trực tiếp phân
phối các luồng liên tục này, mặc dù việc xen kẽ luồng phương tiện
liên tục với luồng điều khiển là khả thi (xem Phần 10.12). Nói cách
khác, RTSP đóng vai trò như một "điều khiển mạng từ xa" cho các máy
chủ đa phương tiện.

Tập hợp các luồng cần điều khiển được xác định bởi một bản mô tả
trình bày (presentation description). Bản ghi nhớ này không định
nghĩa định dạng cho bản mô tả trình bày.

Không tồn tại khái niệm "kết nối RTSP"; thay vào đó, máy chủ duy trì
một phiên được định danh bởi một mã định danh (identifier). Phiên
RTSP không hề bị ràng buộc chặt chẽ với một kết nối ở tầng truyền tải
(transport-level) như kết nối TCP. Trong suốt một phiên RTSP, máy
khách RTSP có thể mở và đóng nhiều kết nối truyền tải tin cậy tới máy
chủ để gửi các yêu cầu RTSP. Ngoài ra, nó cũng có thể sử dụng giao
thức truyền tải không kết nối như UDP.

Các luồng do RTSP điều khiển có thể sử dụng RTP [1], nhưng hoạt động
của RTSP không phụ thuộc vào cơ chế truyền tải dùng để truyền phương
tiện liên tục. Giao thức này được thiết kế tương đồng một cách có chủ
ý về cú pháp và phương thức hoạt động với HTTP/1.1 [2], nhờ đó các cơ
chế mở rộng cho HTTP trong hầu hết trường hợp cũng có thể áp dụng cho
RTSP. Tuy nhiên, RTSP khác biệt với HTTP ở một số khía cạnh quan
trọng:

- RTSP giới thiệu một số phương thức mới và có mã định danh giao
       thức riêng.
- Máy chủ RTSP cần duy trì trạng thái theo mặc định trong hầu hết
       mọi trường hợp, trái ngược với bản chất không trạng thái
       (stateless) của HTTP.
- Cả máy chủ RTSP lẫn máy khách đều có thể phát đi yêu cầu
       (request).
- Dữ liệu phương tiện được truyền ngoài băng tần (out-of-band)
       thông qua một giao thức khác (ngoại trừ một số trường hợp đặc
       biệt).
- RTSP được định nghĩa để sử dụng ISO 10646 (UTF-8) thay vì ISO
       8859-1, phù hợp với các nỗ lực quốc tế hóa HTML hiện tại [3].
- Request-URI luôn chứa URI tuyệt đối. Để tương thích ngược với một
       sai sót mang tính lịch sử, HTTP/1.1 [2] chỉ mang đường dẫn tuyệt
       đối trong yêu cầu và đưa tên máy chủ vào một trường tiêu đề riêng
       biệt.

     Điều này giúp việc triển khai "máy chủ lưu trữ ảo" (virtual
     hosting) trở nên dễ dàng hơn, nơi một máy chủ duy nhất với một địa
     chỉ IP có thể lưu trữ nhiều cây tài liệu.

Giao thức hỗ trợ các thao tác sau:

- **Lấy phương tiện từ máy chủ phương tiện (Retrieval of media):**
  Máy khách có thể yêu cầu một mô tả bản trình bày thông qua
  HTTP hoặc phương thức khác. Nếu bản trình bày được phát đa
  hướng (multicast), mô tả bản trình bày sẽ chứa các địa chỉ và
  cổng multicast được dùng cho phương tiện liên tục. Nếu bản
  trình bày chỉ gửi tới riêng máy khách qua đơn hướng (unicast),
  máy khách sẽ cung cấp địa chỉ đích vì lý do bảo mật.

- **Mời máy chủ phương tiện tham gia hội nghị (Invitation to conference):**
  Một máy chủ phương tiện có thể được "mời" tham gia vào một hội
  nghị hiện có, nhằm phát lại phương tiện vào bản trình bày hoặc
  để ghi lại toàn bộ hay một phần phương tiện trong buổi trình
  bày. Chế độ này rất hữu ích cho các ứng dụng giảng dạy từ xa.
  Nhiều bên trong hội nghị có thể thay phiên nhau "bấm các nút
  điều khiển từ xa".

- **Thêm phương tiện vào bản trình bày hiện có (Addition of media):**
  Đặc biệt đối với các bản trình bày trực tiếp, sẽ rất hữu ích
  nếu máy chủ có thể thông báo cho máy khách biết về các phương
  tiện bổ sung sắp sẵn sàng.

Các yêu cầu RTSP có thể được xử lý bởi các proxy, đường hầm (tunnels)
và bộ nhớ đệm (caches) tương tự như HTTP/1.1.

### 1.2 Yêu cầu (Requirements)

RTSP cần hỗ trợ các khả năng sau:

- Hỗ trợ phân phối âm thanh và video được truyền phát (streaming),
       cả đã lưu trữ lẫn trực tiếp.
- Hỗ trợ phân phối phương tiện truyền phát tới máy khách bằng cả
       multicast và unicast.
- Hỗ trợ ghi lại âm thanh và video.
- Khả năng mở rộng phương thức và tiêu đề.

### 1.3 Thuật ngữ (Terminology)

Một số thuật ngữ đã được kế thừa từ HTTP/1.1 [2]. Các thuật ngữ không
được liệt kê ở đây được định nghĩa tương tự như trong HTTP/1.1.

- **Điều khiển tổng hợp (Aggregate control):**
  Việc kiểm soát nhiều luồng bằng cách sử dụng một dòng thời
  gian duy nhất bởi máy chủ. Đối với các nguồn cấp dữ liệu âm
  thanh/video, điều này có nghĩa là máy khách có thể đưa ra một
  thông điệp phát (play) hoặc tạm dừng (pause) duy nhất để điều
  khiển cả luồng âm thanh lẫn video cùng lúc.

- **Hội nghị (Conference):**
  Một buổi trình diễn đa phương tiện, đa bên, trong đó "đa" mang
  ý nghĩa lớn hơn hoặc bằng một.

Máy khách (Client):
          Máy khách yêu cầu dữ liệu phương tiện liên tục từ máy chủ
          phương tiện.

- **Kết nối (Connection):**
  Một mạch ảo ở tầng truyền tải được thiết lập giữa hai chương
  trình nhằm mục đích giao tiếp.

- **Tệp chứa (Container file):**
  Một tệp có thể chứa nhiều luồng phương tiện mà khi phát cùng
  nhau sẽ tạo thành một bản trình bày. Các máy chủ RTSP có thể
  cung cấp khả năng điều khiển tổng hợp trên các tệp này, mặc dù
  khái niệm tệp chứa không được nhúng trực tiếp vào giao thức.

- **Phương tiện liên tục (Continuous media):**
  Dữ liệu trong đó có mối quan hệ thời gian giữa nguồn phát
  (source) và nơi nhận (sink); nghĩa là nơi nhận phải tái tạo
  lại mối quan hệ thời gian đã tồn tại tại nguồn. Các ví dụ phổ
  biến nhất của phương tiện liên tục là âm thanh và video chuyển
  động. Phương tiện liên tục có thể là thời gian thực (tương
  tác), nơi có mối quan hệ thời gian chặt chẽ giữa nguồn và
  đích, hoặc truyền phát (phát lại), nơi mối quan hệ này ít
  nghiêm ngặt hơn.

- **Thực thể (Entity):**
  Thông tin được chuyển giao dưới dạng tải trọng (payload) của
  một yêu cầu hoặc phản hồi. Một thực thể bao gồm thông tin siêu
  dữ liệu dưới dạng các trường tiêu đề thực thể (entity-header)
  và nội dung dưới dạng thân thực thể (entity-body), như được mô
  tả trong Phần 8.

- **Khởi tạo phương tiện (Media initialization):**
  Khởi tạo cụ thể cho kiểu dữ liệu/codec. Bao gồm những thứ như
  tốc độ xung nhịp (clockrate), bảng màu, v.v. Mọi thông tin độc
  lập với truyền tải mà máy khách yêu cầu để phát lại luồng
  phương tiện đều diễn ra trong giai đoạn khởi tạo phương tiện
  của quá trình thiết lập luồng.

- **Tham số phương tiện (Media parameter):**
  Tham số riêng cho từng loại phương tiện có thể được thay đổi
  trước hoặc trong khi phát lại luồng.

- **Máy chủ phương tiện (Media server):**
  Máy chủ cung cấp dịch vụ phát lại hoặc ghi cho một hoặc nhiều
  luồng phương tiện. Các luồng phương tiện khác nhau trong cùng
  một bản trình bày có thể bắt nguồn từ các máy chủ phương tiện
  khác nhau. Một máy chủ phương tiện có thể nằm trên cùng một
  máy chủ lưu trữ hoặc khác máy chủ lưu trữ với máy chủ web mà
  bản trình bày được gọi từ đó.

Chuyển hướng máy chủ phương tiện (Media server indirection):
          Việc chuyển hướng một yêu cầu RTSP tới một máy chủ phương tiện
          khác.

- **Luồng phương tiện (Media stream):**
  Một phiên bản phương tiện đơn lẻ, ví dụ như một luồng âm thanh
  hoặc một luồng video. Khi sử dụng RTP, một luồng bao gồm tất
  cả các gói RTP và RTCP được tạo bởi một nguồn đồng bộ hóa
  (SSRC) trong một phiên RTP.

- **Thông điệp (Message):**
  Đơn vị cơ sở của việc giao tiếp RTSP, bao gồm một chuỗi các
  byte có cấu trúc được truyền qua kết nối hoặc dưới dạng các
  datagram.

- **Người tham gia (Participant):**
  Thành viên của một hội nghị. Người tham gia có thể là máy móc,
  ví dụ như một máy chủ phương tiện.

- **Bản trình bày (Presentation):**
  Một tập hợp gồm một hoặc nhiều luồng được trình bày tới máy
  khách dưới dạng một góc nhìn thống nhất, sử dụng một bản mô tả
  trình bày.

- **Mô tả bản trình bày (Presentation description):**
  Mô tả bản trình bày chứa thông tin về một hoặc nhiều luồng
  phương tiện trong một bản trình bày, chẳng hạn như cơ chế mã
  hóa, địa chỉ mạng và thông tin về nội dung.

- **Phản hồi (Response):**
  Một thông điệp RTSP do máy chủ gửi về cho máy khách (hoặc
  ngược lại) để đáp lại một thông điệp yêu cầu.

- **Phiên RTSP (RTSP session):**
  Một chuỗi giao dịch RTSP hoàn chỉnh. Đối với một luồng phương
  tiện, phiên bao gồm việc thiết lập luồng với SETUP, khởi động
  luồng bằng PLAY hoặc RECORD, và đóng luồng với TEARDOWN.

- **Thông tin truyền tải (Transport information):**
  Thông tin truyền tải xác định các tham số truyền tải phương
  tiện (chẳng hạn như số hiệu cổng, địa chỉ truyền tải) và các
  giao thức truyền tải thực tế (như RTP).

### 1.4 Các đặc tính của giao thức (Protocol Properties)

RTSP sở hữu các đặc tính sau:

- **Theo từng cặp (Pair-wise):**
  RTSP chỉ hỗ trợ điều khiển theo từng cặp giữa hai bên. Một máy
  khách RTSP điều khiển một máy chủ RTSP duy nhất.

- **Hỗ trợ đa máy chủ (Multi-server capable):**
  Mỗi luồng phương tiện trong một bản trình bày có thể được đặt
  trên một máy chủ phương tiện khác nhau.

Điều khiển thiết bị ghi (Control of recording devices):
          Giao thức có thể điều khiển cả các thiết bị ghi hình/âm thanh
          và các thiết bị phát lại.

- **Tách biệt điều khiển luồng và khởi tạo hội nghị:**
  Việc điều khiển luồng độc lập với việc một hội nghị hoặc phiên
  đa phương tiện được khởi tạo như thế nào. RTSP không đảm nhận
  việc khởi tạo phiên hội nghị ban đầu (ví dụ dùng SIP hoặc
  H.323).

- **Tách biệt điều khiển và phân phối dữ liệu:**
  RTSP không phân phối dữ liệu phương tiện liên tục. Nó điều
  khiển luồng dữ liệu qua kênh điều khiển riêng biệt.

- **Độc lập kênh truyền (Channel independence):**
  Các yêu cầu điều khiển RTSP và luồng dữ liệu phương tiện có
  thể truyền qua các kênh hoặc cổng khác nhau, với các giao thức
  tầng truyền tải khác nhau.

- **Ghép kênh ở tầng ứng dụng (Application-layer multiplexing):**
  Nếu cơ sở hạ tầng mạng hoặc tường lửa yêu cầu, dữ liệu phương
  tiện có thể được xen kẽ (interleaved) trực tiếp vào cùng kết
  nối TCP dùng cho luồng điều khiển RTSP.

- **Thân thiện với HTTP (HTTP-friendly):**
  Ở bất cứ đâu có ý nghĩa, RTSP đều tái sử dụng các khái niệm và
  cơ chế của HTTP để các nhà phát triển và công cụ hiện có có
  thể nhanh chóng làm quen và tích hợp.

- **Khả năng lưu đệm thích hợp (Appropriate caching capabilities):**
  RTSP hỗ trợ các tiêu đề điều khiển lưu đệm tương tự HTTP nhằm
  tối ưu hóa việc phục vụ nội dung.

- **Hiệu quả kinh tế (Cost-effective):**
  Việc tái sử dụng cú pháp HTTP và cơ chế phân phối ngoài băng
  tần giúp việc triển khai máy chủ RTSP trở nên đơn giản và hiệu
  quả về mặt tài nguyên.

- **Độc lập với phương thức truyền tải (Transport-independent):**
  RTSP có thể hoạt động qua cả giao thức tin cậy (TCP) lẫn không
  tin cậy (UDP).

- **Khả năng hỗ trợ đa bên (Multi-party capable):**
  Hỗ trợ phân phối phương tiện tới nhiều bên thông qua
  multicast.

- **Khả năng mở rộng giao thức (Protocol extensibility):**
  Các phương thức mới, trường tiêu đề mới và thẻ tùy chọn có thể
  dễ dàng được thêm vào mà không làm hỏng khả năng tương thích.

Thích hợp cho các ứng dụng chuyên nghiệp:
          RTSP hỗ trợ độ chính xác ở cấp độ khung hình (frame-level
          accuracy) thông qua dấu thời gian SMPTE, giúp ích cho các ứng
          dụng biên tập video chuyên nghiệp.

- **Dễ phân tích cú pháp (Easy to parse):**
  Cú pháp của thông điệp RTSP dựa trên văn bản ASCII tương tự
  HTTP/1.1, giúp việc phân tích cú pháp và gỡ lỗi bằng mắt
  thường trở nên trực quan.

- **Bảo mật (Secure):**
  RTSP có thể tận dụng các cơ chế bảo mật tiêu chuẩn như TLS/SSL
  và các phương pháp xác thực người dùng của HTTP (Basic,
  Digest).

- **Đàm phán truyền tải riêng biệt (Separate transport negotiation):**
  Cơ chế truyền tải phương tiện được đàm phán độc lập thông qua
  trường tiêu đề Transport trong yêu cầu SETUP.

- **Đàm phán mã định danh phiên riêng biệt:**
  Mã định danh phiên do máy chủ cấp phát cho phép ghép nhiều yêu
  cầu vào cùng một ngữ cảnh trạng thái mà không phụ thuộc vào
  kết nối mạng.

### 1.5 Mở rộng RTSP (Extending RTSP)

Vì không phải tất cả các máy chủ phương tiện đều có chức năng như
nhau, các máy chủ theo nhu cầu thực tế sẽ hỗ trợ các tập hợp yêu cầu
khác nhau. Ví dụ:

- Một máy chủ chỉ có khả năng phát lại thì không cần phải hỗ trợ
       yêu cầu RECORD (ghi lại).
- Một máy chủ phục vụ các sự kiện trực tiếp có thể không cần khả
       năng tua tìm (định vị tuyệt đối).
- Một số máy chủ có thể không hỗ trợ việc thiết lập tham số luồng
       và do đó không hỗ trợ GET_PARAMETER và SET_PARAMETER.

Máy chủ NÊN triển khai tất cả các trường tiêu đề được mô tả trong
Phần 12.

### 1.6 Hoạt động tổng thể (Overall Operation)

Mỗi bản trình bày và luồng phương tiện có thể được xác định bằng một
RTSP URL. Bản trình bày tổng thể và các thuộc tính của phương tiện
tạo nên bản trình bày được xác định bởi một tệp mô tả bản trình bày,
định dạng của tệp này nằm ngoài phạm vi của đặc tả này.

Tệp mô tả bản trình bày có thể được máy khách lấy bằng HTTP hoặc các
phương tiện khác chẳng hạn như email, và không nhất thiết phải được
lưu trữ trên máy chủ phương tiện.

RTSP có thể được mở rộng theo ba cách, được liệt kê dưới đây theo thứ
tự mức độ ảnh hưởng của các thay đổi:

- Các phương thức hiện có có thể được mở rộng với các tham số mới,
       miễn là bên nhận có thể bỏ qua các tham số này một cách an toàn
       mà không ảnh hưởng đến tính tương thích. (Điều này tương đương
       với việc thêm các tham số mới vào thẻ HTML). Nếu máy khách cần
       nhận thông báo lỗi phủ định khi phần mở rộng không được hỗ trợ,
       một thẻ tùy chọn tương ứng có thể được thêm vào trường Require:
       (xem Phần 12.32).
- Có thể bổ sung các phương thức mới. Nếu bên nhận thông điệp không
       hiểu yêu cầu, nó sẽ phản hồi bằng mã lỗi 501 (Not Implemented) và
       bên gửi không nên thử lại phương thức này. Máy khách cũng có thể
       sử dụng phương thức OPTIONS để hỏi về các phương thức được máy
       chủ hỗ trợ. Máy chủ NÊN liệt kê các phương thức mà nó hỗ trợ bằng
       cách sử dụng tiêu đề phản hồi Public.
- Một phiên bản mới của giao thức có thể được xác định, cho phép
       thay đổi hầu như tất cả các khía cạnh (ngoại trừ vị trí của số
       phiên bản giao thức).

Đối với mục đích của đặc tả này, một mô tả bản trình bày được giả
định là mô tả một hoặc nhiều bản trình bày, mỗi bản trình bày duy trì
một trục thời gian chung. Để trình bày đơn giản và không mất tính
tổng quát, giả định rằng mô tả bản trình bày chứa chính xác một bản
trình bày như vậy. Một bản trình bày có thể chứa nhiều luồng phương
tiện.

Tệp mô tả bản trình bày chứa mô tả về các luồng phương tiện tạo nên
bản trình bày, bao gồm cơ chế mã hóa, ngôn ngữ và các tham số khác
cho phép máy khách chọn sự kết hợp phù hợp nhất giữa các phương tiện.

Trong bản mô tả bản trình bày này, mỗi luồng phương tiện có thể điều
khiển độc lập bằng RTSP được xác định bởi một RTSP URL, trỏ tới máy
chủ phương tiện xử lý luồng phương tiện cụ thể đó và đặt tên cho
luồng được lưu trữ trên máy chủ đó. Nhiều luồng phương tiện có thể
được đặt trên các máy chủ khác nhau; ví dụ luồng âm thanh và luồng
video có thể được chia tách trên các máy chủ để chia tải. Bản mô tả
cũng liệt kê những phương thức truyền tải nào mà máy chủ có khả năng
thực hiện.

Bên cạnh các tham số phương tiện, địa chỉ mạng đích và số cổng cũng
cần được xác định. Có thể phân biệt một số chế độ hoạt động:

- **Đơn hướng (Unicast):**
  Phương tiện được truyền tới nguồn gửi yêu cầu RTSP, với số
  cổng do máy khách chọn. Ngoài ra, phương tiện có thể được
  truyền trên cùng một luồng đáng tin cậy như RTSP.

- **Đa hướng, máy chủ chọn địa chỉ (Multicast, server chooses address):**
  Máy chủ phương tiện chọn địa chỉ và cổng multicast. Đây là
  trường hợp điển hình cho truyền phát trực tiếp hoặc gần theo
  yêu cầu.

- **Đa hướng, máy khách chọn địa chỉ (Multicast, client chooses address):**
  Nếu máy chủ tham gia vào một hội nghị multicast hiện có, địa
  chỉ multicast, cổng và khóa mã hóa sẽ được đưa ra bởi mô tả
  hội nghị, được thiết lập bằng các phương tiện nằm ngoài phạm
  vi của đặc tả này.

### 1.7 Các trạng thái của RTSP (RTSP States)

RTSP điều khiển một luồng có thể được gửi qua một giao thức riêng
biệt, độc lập với kênh điều khiển. Ví dụ, điều khiển RTSP có thể diễn
ra trên một kết nối TCP trong khi dữ liệu truyền qua UDP. Do đó, việc
phân phối dữ liệu vẫn tiếp tục ngay cả khi máy chủ phương tiện không
nhận được yêu cầu RTSP nào.

Ngoài ra, trong suốt vòng đời của mình, một luồng phương tiện đơn lẻ
có thể được điều khiển bởi các yêu cầu RTSP được phát ra tuần tự trên
các kết nối TCP khác nhau. Do đó, máy chủ cần duy trì "trạng thái
phiên" (session state) để có thể liên kết các yêu cầu RTSP với một
luồng cụ thể. Các chuyển đổi trạng thái được mô tả chi tiết trong Phụ
lục A.

Nhiều phương thức trong RTSP không tác động đến trạng thái. Tuy
nhiên, các phương thức sau đây đóng vai trò trung tâm trong việc xác
định việc phân bổ và sử dụng tài nguyên luồng trên máy chủ: SETUP,
PLAY, RECORD, PAUSE và TEARDOWN.

- **SETUP:**
  Khiến máy chủ phân bổ tài nguyên cho một luồng và bắt đầu một
  phiên RTSP.

- **PLAY và RECORD:**
  Bắt đầu truyền dữ liệu trên luồng đã được phân bổ qua SETUP.

- **PAUSE:**
  Tạm dừng luồng mà không giải phóng tài nguyên trên máy chủ.

- **TEARDOWN:**
  Giải phóng các tài nguyên liên kết với luồng. Phiên RTSP chấm
  dứt tồn tại trên máy chủ.

Các phương thức RTSP tác động đến trạng thái sử dụng trường tiêu đề
Session (Phần 12.37) để xác định phiên RTSP đang được thao tác trạng
thái. Máy chủ tạo các mã định danh phiên để đáp ứng các yêu cầu SETUP
(Phần 10.4).

### 1.8 Mối quan hệ với các giao thức khác (Relationship with Other Protocols)

RTSP có một số điểm tương đồng về mặt chức năng với HTTP. Nó cũng có
thể tương tác với HTTP ở chỗ điểm tiếp xúc ban đầu với nội dung
truyền phát thường được thực hiện thông qua một trang web. Đặc tả
giao thức hiện tại nhằm mục đích cho phép các điểm chuyển giao khác
nhau giữa máy chủ web và máy chủ phương tiện triển khai RTSP. Ví dụ:
mô tả bản trình bày có thể được lấy bằng HTTP hoặc RTSP, giúp giảm số
lượt truyền (roundtrips) trong các kịch bản dựa trên trình duyệt web,
nhưng cũng cho phép các máy chủ và máy khách RTSP độc lập không phụ
thuộc vào HTTP.

Tuy nhiên, RTSP khác biệt cơ bản với HTTP ở chỗ việc phân phối dữ
liệu diễn ra ngoài băng tần trong một giao thức khác. HTTP là một
giao thức bất đối xứng, nơi máy khách phát đi yêu cầu và máy chủ phản
hồi. Trong RTSP, cả máy khách và máy chủ phương tiện đều có thể phát
đi yêu cầu. Các yêu cầu RTSP cũng không phải là phi trạng thái
(stateless); chúng có thể thiết lập tham số và tiếp tục điều khiển
luồng phương tiện rất lâu sau khi...

yêu cầu đã được xác nhận.

     Việc tái sử dụng các chức năng của HTTP mang lại lợi thế trong ít
     nhất hai lĩnh vực, cụ thể là bảo mật và máy chủ ủy quyền (proxies).
     Các yêu cầu là rất tương đồng, do đó việc có khả năng kế thừa các
     thành quả của HTTP về bộ nhớ đệm (caches), máy chủ ủy quyền
     (proxies) và cơ chế xác thực (authentication) là vô cùng giá trị.

Mặc dù hầu hết các phương tiện thời gian thực sẽ sử dụng RTP làm giao
thức truyền tải, nhưng RTSP không bị ràng buộc cứng với RTP.

RTSP giả định sự tồn tại của một định dạng mô tả bản trình bày có thể
thể hiện cả các thuộc tính tĩnh và thuộc tính thời gian của một bản
trình bày chứa nhiều luồng phương tiện.

## 2 Quy ước ký hiệu (Notational Conventions)

Vì nhiều định nghĩa và cú pháp giống hệt với HTTP/1.1, đặc tả này dẫn
chiếu đến [H2] thay vì lặp lại toàn bộ đặc tả ở đây. Để ngắn gọn, ký
hiệu [HX.Y] được hiểu là tham chiếu đến Phần X.Y của đặc tả HTTP/1.1
hiện hành (RFC 2068 [2]).

Tất cả các cơ chế được chỉ định trong tài liệu này đều được mô tả
bằng cả văn xuôi và dạng Backus-Naur mở rộng (Augmented BNF - ABNF)
tương tự như dạng được sử dụng trong [H2.1]. Dạng này được mô tả chi
tiết trong RFC 2234 [22], với điểm khác biệt là đặc tả này sử dụng
tên chữ thường cho các chuỗi kết thúc (terminal strings). Các điểm
khác biệt so với HTTP/1.1 bao gồm việc sử dụng bộ ký tự UTF-8 [3]
trong các chuỗi văn bản và các dải số được biểu diễn dưới dạng
"min*max" thay vì "min*#max" như trong RFC 822 [23]. Ngoài ra, ký tự
"#" không được sử dụng; thay vào đó, các danh sách được mô tả tường
minh trong quy tắc cú pháp. Các token từ vựng được phân tách bằng
khoảng trắng từ (WS) hoặc CRLF.

Trong đặc tả này, chúng tôi sử dụng các ký hiệu sau:

- tùy chọn (optional)
     #   không sử dụng (not used)
     |   các lựa chọn thay thế (alternatives)
     ()  nhóm (grouping)
     []  tùy chọn (tương đương với *1)
     " " các chuỗi kết thúc (terminal strings)

Các từ được viết hoàn toàn bằng chữ hoa chỉ ra rằng phần tử đó là một
ký hiệu kết thúc (terminal symbol). Để dễ đọc, chúng tôi sẽ viết các
ký hiệu không kết thúc bằng dấu gạch nối, trong khi các phần tử thuộc
cú pháp cốt lõi được viết bằng chữ thường. Ngược lại với [H2.2],
chúng tôi không sử dụng cấu trúc "#" cho danh sách phân tách bằng dấu
phẩy.

Trong bản ghi nhớ này, chúng tôi sử dụng các đoạn văn thụt lề để cung
cấp bối cảnh và lý do thiết kế. Điều này nhằm giúp những độc giả
không tham gia vào quá trình xây dựng đặc tả hiểu được lý do tại sao
mọi thứ lại được thiết kế như vậy trong RTSP.

## 3 Các tham số giao thức (Protocol Parameters)

### 3.1 Phiên bản RTSP (RTSP Version)

Áp dụng [H3.1], trong đó HTTP được thay thế bằng RTSP.

### 3.2 RTSP URL

Các lược đồ "rtsp" và "rtspu" được sử dụng để tham chiếu đến các tài
nguyên mạng thông qua giao thức RTSP. Phần này định nghĩa cú pháp và
ngữ nghĩa cụ thể của lược đồ cho các RTSP URL.

rtsp_URL  =   ( "rtsp:" | "rtspu:" )
                 "//" host [ ":" port ] [ abs_path ]
host      =   <A legal Internet host domain name of IP address
                 (in dotted decimal form), as defined by Section 2.1

of RFC 1123 \cite{rfc1123}>
port      =   *DIGIT

abs_path được định nghĩa trong [H3.2.1].

     Lưu ý rằng các mã định danh đoạn (fragment) và truy vấn (query)
     hiện chưa có ý nghĩa được xác định rõ ràng tại thời điểm này, và
     việc diễn giải được giao cho máy chủ RTSP.

Lược đồ rtsp yêu cầu các lệnh phải được phát thông qua một giao thức
tin cậy (trong mạng Internet là TCP), trong khi lược đồ rtspu xác
định một giao thức không tin cậy (trong mạng Internet là UDP).

Nếu cổng để trống hoặc không được cung cấp, cổng mặc định 554 được
giả định. Ngữ nghĩa là tài nguyên được xác định có thể được điều
khiển bởi RTSP tại máy chủ đang lắng nghe các kết nối TCP (lược đồ
"rtsp") hoặc các gói tin UDP (lược đồ "rtspu") trên cổng đó của host,
và Request-URI cho tài nguyên đó chính là rtsp_URL.

NÊN tránh sử dụng địa chỉ IP trực tiếp trong URL bất cứ khi nào có
thể (xem RFC 1924 [19]).

Một bản trình bày hoặc một luồng được xác định bởi một mã định danh
phương tiện dạng văn bản, sử dụng bộ ký tự và quy ước thoát ký tự
[H3.2] của URL (RFC 1738 [20]). Các URL có thể tham chiếu đến một
luồng đơn lẻ hoặc một tập hợp các luồng, tức là một bản trình bày.
Theo đó, các yêu cầu được mô tả trong Phần 10 có thể áp dụng cho toàn
bộ bản trình bày hoặc cho một luồng riêng lẻ trong bản trình bày. Lưu
ý rằng một số phương thức yêu cầu chỉ có thể áp dụng cho luồng, không
áp dụng cho bản trình bày và ngược lại.

Ví dụ, RTSP URL:
     rtsp://media.example.com:554/twister/audiotrack

xác định luồng âm thanh bên trong bản trình bày "twister", luồng này
có thể được điều khiển thông qua các yêu cầu RTSP được gửi qua kết
nối TCP tới cổng 554 của máy chủ media.example.com.

Tương tự, RTSP URL:
     rtsp://media.example.com:554/twister

xác định bản trình bày "twister", có thể được cấu thành từ cả luồng
âm thanh và luồng video.

Điều này không hàm ý một cách chuẩn mực duy nhất để tham chiếu các
luồng trong URL. Bản mô tả bản trình bày sẽ định nghĩa các mối quan
hệ phân cấp trong bản trình bày và các URL dành cho từng luồng riêng
lẻ. Một bản mô tả trình bày có thể đặt tên cho một luồng là "a.mov"
và toàn bộ bản trình bày là "b.mov".

Các thành phần đường dẫn của RTSP URL là mờ (opaque) đối với máy
khách và không hàm ý bất kỳ cấu trúc hệ thống tệp cụ thể nào trên máy
chủ.

     Sự tách rời này cũng cho phép các bản mô tả trình bày được sử dụng
     với các giao thức điều khiển phương tiện không phải RTSP chỉ bằng
     cách thay thế lược đồ trong URL.

### 3.3 Mã định danh hội nghị (Conference Identifiers)

Các mã định danh hội nghị là mờ (opaque) đối với RTSP và được mã hóa
bằng các phương thức mã hóa URI tiêu chuẩn (nghĩa là LWS được thoát
bằng ký tự %). Chúng có thể chứa bất kỳ giá trị octet nào. Mã định
danh hội nghị BẮT BUỘC phải là duy nhất trên phạm vi toàn cầu. Đối
với H.323, giá trị conferenceID sẽ được sử dụng.

conference-id =   1*xchar

     Mã định danh hội nghị được sử dụng để cho phép các phiên RTSP thu
     nhận các tham số từ các hội nghị đa phương tiện mà máy chủ phương
     tiện đang tham gia. Các hội nghị này được tạo ra bởi các giao thức
     nằm ngoài phạm vi của đặc tả này, ví dụ: H.323 [13] hoặc SIP [12].
     Thay vì máy khách RTSP phải tự cung cấp thông tin truyền tải một
     cách rõ ràng, nó có thể yêu cầu máy chủ phương tiện sử dụng các giá
     trị sẵn có trong bản mô tả hội nghị.

### 3.4 Mã định danh phiên (Session Identifiers)

Mã định danh phiên là các chuỗi mờ (opaque strings) có độ dài tùy ý.
Khoảng trắng tuyến tính (linear white space) phải được thoát theo
chuẩn URL. Một mã định danh phiên BẮT BUỘC phải được chọn ngẫu nhiên
và BẮT BUỘC phải có độ dài ít nhất tám octet để gây khó khăn hơn cho
việc đoán mò (Xem Phần 16).

     session-id   =   1*( ALPHA | DIGIT | safe )

### 3.5 Dấu thời gian tương đối SMPTE (SMPTE Relative Timestamps)

Dấu thời gian tương đối SMPTE thể hiện thời gian tương đối so với
thời điểm bắt đầu của đoạn clip. Các dấu thời gian tương đối được
biểu diễn dưới dạng mã thời gian SMPTE để đạt được độ chính xác truy
cập ở cấp độ từng khung hình. Mã thời gian có định dạng
hours:minutes:seconds:frames.subframes, với mốc gốc tại thời điểm bắt
đầu của clip. Định dạng SMPTE mặc định là "SMPTE 30 drop", với tốc độ
khung hình là 29.97 khung hình mỗi giây. Các mã SMPTE khác CÓ THỂ
được hỗ trợ (chẳng hạn như "SMPTE 25") thông qua việc sử dụng thay
thế "smpte time". Trường "frames" trong giá trị thời gian có thể nhận
các giá trị từ 0 đến 29. Sự khác biệt giữa 30 và 29.97 khung
hình/giây được xử lý bằng cách bỏ qua hai chỉ số khung hình đầu tiên
(giá trị 00 và 01) của mỗi phút, ngoại trừ mỗi phút thứ mười. Nếu giá
trị khung hình bằng 0, nó có thể được lược bỏ. Các khung hình con
(subframes) được đo bằng một phần trăm của một khung hình.

smpte-range  =   smpte-type "=" smpte-time "-" [ smpte-time ]
smpte-type   =   "smpte" | "smpte-30-drop" | "smpte-25"
                                   ; các mã thời gian khác có thể bổ sung
smpte-time   =   1*2DIGIT ":" 1*2DIGIT ":" 1*2DIGIT [ ":" 1*2DIGIT ]
                       [ "." 1*2DIGIT ]

Ví dụ (Examples):
     smpte=10:12:33:20-
     smpte=10:07:33-
     smpte=10:07:00-10:07:33:05.01
     smpte-25=10:07:00-10:07:33:05.01

### 3.6 Thời gian phát bình thường (Normal Play Time - NPT)

Thời gian phát bình thường (Normal Play Time - NPT) biểu thị vị trí
tuyệt đối của luồng tương đối so với thời điểm bắt đầu của bản trình
bày. Dấu thời gian bao gồm một số thập phân. Phần bên trái dấu thập
phân có thể được biểu thị bằng giây hoặc bằng giờ, phút và giây. Phần
bên phải của dấu thập phân đo các phần phân số của giây.

Thời điểm bắt đầu của một bản trình bày tương ứng với 0.0 giây. Các
giá trị âm không được định nghĩa. Hằng số đặc biệt "now" được định
nghĩa là thời điểm hiện tại của một sự kiện trực tiếp. Nó chỉ có thể
được sử dụng cho các sự kiện trực tiếp.

NPT được định nghĩa tương tự như trong DSM-CC: "Theo trực giác, NPT
là chiếc đồng hồ mà người xem liên kết với một chương trình. Nó
thường được hiển thị bằng số trên các thiết bị VCR. NPT tiến bình
thường khi ở chế độ phát bình thường (scale = 1), tiến với tốc độ
nhanh hơn khi tua nhanh (tỷ lệ scale dương cao), giảm dần khi tua lùi
(tỷ lệ scale âm cao) và cố định ở chế độ tạm dừng. NPT (về mặt logic)
tương đương với các mã thời gian SMPTE." [5]

npt-range    =   ( npt-time "-" [ npt-time ] ) | ( "-" npt-time )
npt-time     =   "now" | npt-sec | npt-hhmmss
npt-sec      =   1*DIGIT [ "." *DIGIT ]
npt-hhmmss   =   npt-hh ":" npt-mm ":" npt-ss [ "." *DIGIT ]
npt-hh       =   1*DIGIT     ; bất kỳ số dương nào
npt-mm       =   1*2DIGIT    ; 0-59
npt-ss       =   1*2DIGIT    ; 0-59

Ví dụ (Examples):
     npt=123.45-125
     npt=12:05:35.3-
     npt=now-

     Cú pháp tuân thủ theo tiêu chuẩn ISO 8601. Ký hiệu npt-sec được tối
     ưu hóa cho việc tạo tự động bằng máy, ký hiệu npt-hhmmss dành cho
     con người đọc. Hằng số "now" cho phép máy khách yêu cầu...

nhận luồng dữ liệu trực tiếp thay vì phiên bản đã lưu trữ hoặc bị
     trì hoãn thời gian. Điều này là cần thiết vì cả thời gian tuyệt đối
     lẫn thời gian bằng 0 đều không phù hợp cho trường hợp này.

### 3.7 Thời gian tuyệt đối (Absolute Time)

     Thời gian tuyệt đối được biểu thị dưới dạng dấu thời gian ISO 8601,
     sử dụng chuẩn UTC (GMT). Các phần phân số của giây có thể được chỉ
     định.

     utc-range    =   "clock" "=" utc-time "-" [ utc-time ]
     utc-time     =   utc-date "T" utc-time "Z"
     utc-date     =   8DIGIT                    ; < YYYYMMDD >
     utc-time     =   6DIGIT [ "." fraction ]   ; < HHMMSS.fraction >

     Ví dụ cho ngày 8 tháng 11 năm 1996 lúc 14 giờ 37 phút 20 giây và 1/4 giây UTC:

     19961108T143720.25Z

### 3.8 Thẻ tùy chọn (Option Tags)

Thẻ tùy chọn là các mã định danh duy nhất được sử dụng để chỉ định
các tùy chọn mới trong RTSP. Các thẻ này được sử dụng trong các
trường tiêu đề Require (Phần 12.32) và Proxy-Require (Phần 12.27).

Cú pháp (Syntax):

     option-tag   =   1*xchar

Người tạo ra một tùy chọn RTSP mới nên đặt tiền tố cho tùy chọn đó
bằng tên miền đảo ngược (ví dụ: "com.foo.mynewfeature" là một cái tên
phù hợp cho một tính năng mà người phát minh ra nó có thể liên hệ tại
"foo.com"), hoặc đăng ký tùy chọn mới với Cơ quan cấp số hiệu
Internet (IANA).

#### 3.8.1 Đăng ký thẻ tùy chọn mới với IANA (Registering New Option Tags with IANA)

Khi đăng ký một tùy chọn RTSP mới, cần cung cấp các thông tin sau:

- Tên và mô tả của tùy chọn. Tên có thể có độ dài bất kỳ, nhưng NÊN
       không dài quá 20 ký tự. Tên BẮT BUỘC không được chứa khoảng
       trắng, ký tự điều khiển hoặc dấu chấm.
- Chỉ dẫn về tổ chức có quyền kiểm soát thay đổi đối với tùy chọn
       (ví dụ: IETF, ISO, ITU-T, các tổ chức tiêu chuẩn hóa quốc tế
       khác, một liên minh hoặc một công ty/nhóm công ty cụ thể);

* Tài liệu tham chiếu đến phần mô tả sâu hơn, nếu có sẵn, ví dụ
       (theo thứ tự ưu tiên) một RFC, một bài báo đã xuất bản, một hồ sơ
       bằng sáng chế, một báo cáo kỹ thuật, mã nguồn có tài liệu hoặc sổ
       tay hướng dẫn máy tính;
- Đối với các tùy chọn độc quyền, thông tin liên hệ (địa chỉ bưu
       điện và email);

## 4 Thông điệp RTSP (RTSP Message)

RTSP là một giao thức dạng văn bản và sử dụng bộ ký tự ISO 10646
trong bảng mã UTF-8 (RFC 2279 [21]). Các dòng được kết thúc bằng
CRLF, nhưng các bên nhận cũng nên sẵn sàng xử lý các ký tự CR và LF
đứng riêng rẽ như các dấu kết thúc dòng.

     Các giao thức dạng văn bản giúp việc thêm các tham số tùy chọn theo
     phương thức tự mô tả trở nên dễ dàng hơn. Vì số lượng tham số và
     tần suất của các lệnh là thấp, hiệu quả xử lý không phải là mối
     quan tâm lớn. Các giao thức dạng văn bản, nếu được thiết kế cẩn
     thận, cũng cho phép dễ dàng triển khai các bản thử nghiệm nghiên
     cứu bằng các ngôn ngữ kịch bản như Tcl, Visual Basic và Perl.

     Bộ ký tự 10646 tránh việc chuyển đổi bộ ký tự phức tạp, nhưng hoàn
     toàn trong suốt đối với ứng dụng miễn là US-ASCII đang được sử
     dụng. Đây cũng là bảng mã được sử dụng cho RTCP. ISO 8859-1 chuyển
     dịch trực tiếp sang Unicode với octet bậc cao bằng 0. Các ký tự ISO
     8859-1 có bit quan trọng nhất được bật sẽ được biểu diễn dưới dạng
     1100001x 10xxxxxx (Xem RFC 2279 [21]).

Các thông điệp RTSP có thể được truyền tải qua bất kỳ giao thức tầng
truyền tải cấp thấp hơn nào mà sạch 8-bit (8-bit clean).

Các yêu cầu chứa các phương thức, đối tượng mà phương thức thao tác
trên đó và các tham số để mô tả thêm về phương thức. Các phương thức
mang tính bất biến (idempotent), trừ khi có quy định khác. Các phương
thức cũng được thiết kế để yêu cầu ít hoặc không cần duy trì trạng
thái tại máy chủ phương tiện.

### 4.1 Các loại thông điệp (Message Types)

Xem [H4.1]

### 4.2 Các tiêu đề thông điệp (Message Headers)

Xem [H4.2]

### 4.3 Thân thông điệp (Message Body)

Xem [H4.3]

### 4.4 Độ dài thông điệp (Message Length)

Khi thân thông điệp được bao gồm trong một thông điệp, độ dài của
thân thông điệp đó được xác định bởi một trong các quy tắc sau (theo
thứ tự ưu tiên):

1.     Bất kỳ thông điệp phản hồi nào BẮT BUỘC KHÔNG ĐƯỢC bao gồm
          thân thông điệp (chẳng hạn như các phản hồi 1xx, 204 và 304)
          luôn được kết thúc bởi dòng trống đầu tiên sau các trường tiêu
          đề, bất kể các trường tiêu đề thực thể hiện diện trong thông
          điệp. (Lưu ý: Một dòng trống chỉ bao gồm CRLF).

2.     Nếu trường tiêu đề Content-Length (Phần 12.14) hiện diện, giá
          trị của nó tính bằng byte đại diện cho độ dài của thân thông
          điệp. Nếu trường tiêu đề này không hiện diện, giá trị mặc định
          bằng 0 được giả định.

3.     Bằng việc máy chủ đóng kết nối. (Việc đóng kết nối không thể
          được sử dụng để chỉ thị kết thúc thân yêu cầu, vì điều đó sẽ
          khiến máy chủ không còn khả năng gửi lại phản hồi).

Lưu ý rằng RTSP (tại thời điểm này) không hỗ trợ mã hóa truyền tải
"phân đoạn" (chunked transfer coding - xem [H3.6]) của HTTP/1.1 và
yêu cầu sự hiện diện của trường tiêu đề Content-Length.

     Với độ dài vừa phải của các mô tả bản trình bày được trả về, máy
     chủ luôn có thể xác định được độ dài của nó, ngay cả khi nó được
     tạo động, khiến mã hóa truyền tải chunked trở nên không cần thiết.
     Mặc dù Content-Length bắt buộc phải hiện diện nếu có bất kỳ thân
     thực thể nào, các quy tắc vẫn đảm bảo hành vi hợp lý ngay cả khi độ
     dài không được cung cấp một cách tường minh.

## 5 Các trường tiêu đề chung (General Header Fields)

Xem [H4.5], ngoại trừ việc các tiêu đề Pragma, Transfer-Encoding và
Upgrade không được định nghĩa:

      general-header     =     Cache-Control     ; Phần 12.8
                         |     Connection        ; Phần 12.10
                         |     Date              ; Phần 12.18
                         |     Via               ; Phần 12.43

## 6 Yêu cầu (Request)

Một thông điệp yêu cầu từ máy khách tới máy chủ hoặc ngược lại bao
gồm, trong dòng đầu tiên của thông điệp đó, phương thức được áp dụng
cho tài nguyên, mã định danh của tài nguyên và phiên bản giao thức
đang được sử dụng.

Request      =       Request-Line          ; Phần 6.1
                    *(      general-header        ; Phần 5
                    |       request-header        ; Phần 6.2
                    |       entity-header )       ; Phần 8.1
                            CRLF
                            [ message-body ]      ; Phần 4.3

### 6.1 Dòng yêu cầu (Request Line)

  Request-Line = Method SP Request-URI SP RTSP-Version CRLF

Method         =         "DESCRIBE"              ; Phần 10.2
                  |         "ANNOUNCE"              ; Phần 10.3
                  |         "GET_PARAMETER"         ; Phần 10.8
                  |         "OPTIONS"               ; Phần 10.1
                  |         "PAUSE"                 ; Phần 10.6
                  |         "PLAY"                  ; Phần 10.5
                  |         "RECORD"                ; Phần 10.11
                  |         "REDIRECT"              ; Phần 10.10
                  |         "SETUP"                 ; Phần 10.4
                  |         "SET_PARAMETER"         ; Phần 10.9
                  |         "TEARDOWN"              ; Phần 10.7
                  |         extension-method

  extension-method = token

  Request-URI = "*" | absolute_URI

  RTSP-Version = "RTSP" "/" 1*DIGIT "." 1*DIGIT

### 6.2 Các trường tiêu đề yêu cầu (Request Header Fields)

  request-header  =          Accept                   ; Phần 12.1
                  |          Accept-Encoding          ; Phần 12.2
                  |          Accept-Language          ; Phần 12.3
                  |          Authorization            ; Phần 12.5
                  |          From                     ; Phần 12.20
                  |          If-Modified-Since        ; Phần 12.23
                  |          Range                    ; Phần 12.29
                  |          Referer                  ; Phần 12.30
                  |          User-Agent               ; Phần 12.41

Lưu ý rằng trái ngược với HTTP/1.1 [2], các yêu cầu RTSP luôn luôn
chứa URL tuyệt đối (nghĩa là bao gồm cả lược đồ scheme, host và số
cổng port) thay vì chỉ chứa đường dẫn tuyệt đối.

HTTP/1.1 yêu cầu các máy chủ phải hiểu URL tuyệt đối, nhưng các máy
     khách được kỳ vọng sẽ sử dụng tiêu đề yêu cầu Host. Điều này hoàn
     toàn là vì khả năng tương thích ngược với các máy chủ HTTP/1.0, một
     yếu tố cân nhắc không áp dụng cho RTSP.

Dấu hoa thị "*" trong Request-URI có nghĩa là yêu cầu không áp dụng
cho một tài nguyên cụ thể, mà áp dụng cho chính máy chủ, và chỉ được
phép khi phương thức được sử dụng không nhất thiết phải áp dụng cho
một tài nguyên. Một ví dụ là:

```http
OPTIONS * RTSP/1.0
```

## 7 Phản hồi (Response)

[H6] được áp dụng ngoại trừ việc HTTP-Version được thay thế bằng
RTSP-Version. Ngoài ra, RTSP định nghĩa thêm các mã trạng thái bổ
sung và không định nghĩa một số mã của HTTP. Các mã phản hồi hợp lệ
và các phương thức mà chúng có thể được sử dụng được định nghĩa trong
Bảng 1.

Sau khi nhận và giải thích một thông điệp yêu cầu, bên nhận sẽ phản
hồi bằng một thông điệp phản hồi RTSP.

     Response    =     Status-Line         ; Phần 7.1
                 *(    general-header      ; Phần 5
                 |     response-header     ; Phần 7.1.2
                 |     entity-header )     ; Phần 8.1
                       CRLF
                       [ message-body ]    ; Phần 4.3

### 7.1 Dòng trạng thái (Status-Line)

Dòng đầu tiên của một thông điệp Phản hồi là Status-Line, bao gồm
phiên bản giao thức theo sau bởi một mã trạng thái dạng số, và cụm từ
văn bản liên kết với mã trạng thái đó, với mỗi phần tử được phân tách
bởi các ký tự SP. Không cho phép CR hoặc LF ngoại trừ trong chuỗi
CRLF cuối cùng.

Status-Line =   RTSP-Version SP Status-Code SP Reason-Phrase CRLF

#### 7.1.1 Mã trạng thái và Cụm từ giải thích (Status Code and Reason Phrase)

Phần tử Status-Code là một mã kết quả số nguyên gồm 3 chữ số cho nỗ
lực hiểu và đáp ứng yêu cầu. Các mã này được định nghĩa đầy đủ trong
Phần 11. Reason-Phrase nhằm mục đích đưa ra mô tả ngắn gọn bằng văn
bản về Status-Code. Status-Code dành cho máy tự động xử lý và Reason-
Phrase dành cho người dùng. Máy khách không bắt buộc phải kiểm tra
hoặc hiển thị Reason-Phrase.

Chữ số đầu tiên của Status-Code xác định lớp phản hồi. Hai chữ số
cuối không có bất kỳ vai trò phân loại nào. Có 5 giá trị cho chữ số
đầu tiên:

- 1xx: Thông tin (Informational) - Đã nhận yêu cầu, đang tiếp tục
       quá trình
- 2xx: Thành công (Success) - Hành động đã được nhận, hiểu và chấp
       nhận thành công
- 3xx: Chuyển hướng (Redirection) - Cần thực hiện thêm hành động để
       hoàn tất yêu cầu
- 4xx: Lỗi máy khách (Client Error) - Yêu cầu chứa cú pháp sai hoặc
       không thể thực hiện được
- 5xx: Lỗi máy chủ (Server Error) - Máy chủ không thực hiện được
       một yêu cầu có vẻ hợp lệ

Các giá trị riêng lẻ của các mã trạng thái dạng số được định nghĩa
cho RTSP/1.0, và một tập hợp ví dụ về các Reason-Phrase tương ứng,
được trình bày dưới đây. Các cụm từ giải thích (reason phrases) được
liệt kê ở đây chỉ mang tính khuyến nghị - chúng có thể được thay thế
bằng các từ tương đương cục bộ mà không ảnh hưởng đến giao thức. Lưu
ý rằng RTSP áp dụng hầu hết các mã trạng thái của HTTP/1.1 [2] và bổ
sung thêm các mã trạng thái riêng của RTSP bắt đầu từ x50 để tránh
xung đột với các mã trạng thái HTTP mới được định nghĩa.

Status-Code  =     "100"      ; Continue
                |     "200"      ; OK
                |     "201"      ; Created
                |     "250"      ; Low on Storage Space
                |     "300"      ; Multiple Choices
                |     "301"      ; Moved Permanently
                |     "302"      ; Moved Temporarily
                |     "303"      ; See Other
                |     "304"      ; Not Modified
                |     "305"      ; Use Proxy
                |     "400"      ; Bad Request
                |     "401"      ; Unauthorized
                |     "402"      ; Payment Required
                |     "403"      ; Forbidden
                |     "404"      ; Not Found
                |     "405"      ; Method Not Allowed
                |     "406"      ; Not Acceptable
                |     "407"      ; Proxy Authentication Required
                |     "408"      ; Request Time-out
                |     "410"      ; Gone
                |     "411"      ; Length Required
                |     "412"      ; Precondition Failed
                |     "413"      ; Request Entity Too Large
                |     "414"      ; Request-URI Too Large
                |     "415"      ; Unsupported Media Type
                |     "451"      ; Parameter Not Understood
                |     "452"      ; Conference Not Found
                |     "453"      ; Not Enough Bandwidth
                |     "454"      ; Session Not Found
                |     "455"      ; Method Not Valid in This State
                |     "456"      ; Header Field Not Valid for Resource
                |     "457"      ; Invalid Range
                |     "458"      ; Parameter Is Read-Only
                |     "459"      ; Aggregate operation not allowed
                |     "460"      ; Only aggregate operation allowed
                |     "461"      ; Unsupported transport
                |     "462"      ; Destination unreachable
                |     "500"      ; Internal Server Error
                |     "501"      ; Not Implemented
                |     "502"      ; Bad Gateway
                |     "503"      ; Service Unavailable
                |     "504"      ; Gateway Time-out
                |     "505"      ; RTSP Version not supported
                |     "551"      ; Option not supported
                |     extension-code

extension-code  =     3DIGIT

Reason-Phrase  =     *<TEXT, excluding CR, LF>

Các mã trạng thái RTSP có thể mở rộng được. Các ứng dụng RTSP không
bắt buộc phải hiểu ý nghĩa của tất cả các mã trạng thái đã đăng ký,
mặc dù việc hiểu như vậy rõ ràng là rất đáng mong muốn. Tuy nhiên,
các ứng dụng PHẢI (MUST) hiểu lớp của bất kỳ mã trạng thái nào, như
được chỉ ra bởi chữ số đầu tiên, và coi bất kỳ phản hồi nào không
được nhận biết là tương đương với mã trạng thái x00 của lớp đó, với
ngoại lệ là một phản hồi không được nhận biết KHÔNG ĐƯỢC (MUST NOT)
lưu vào bộ nhớ cache. Ví dụ, nếu một mã trạng thái không được nhận
biết là 431 được nhận bởi máy khách, nó có thể giả định một cách an
toàn rằng có điều gì đó không ổn với yêu cầu của mình và xử lý phản
hồi như thể nó đã nhận được mã trạng thái 400. Trong các trường hợp
như vậy, các tác nhân người dùng NÊN (SHOULD) hiển thị cho người dùng
thực thể được trả về cùng với phản hồi, vì thực thể đó có khả năng
chứa thông tin dạng người đọc được giải thích trạng thái bất thường.

| Mã (Code) | Cụm từ giải thích (Reason Phrase) | Phương thức áp dụng (Methods) |
| :--- | :--- | :--- |
| 100 | Continue | all |
| 200 | OK | all |
| 201 | Created | RECORD |
| 250 | Low on Storage Space | RECORD |
| 300 | Multiple Choices | all |
| 301 | Moved Permanently | all |
| 302 | Moved Temporarily | all |
| 303 | See Other | all |
| 305 | Use Proxy | all |
| 400 | Bad Request | all |
| 401 | Unauthorized | all |
| 402 | Payment Required | all |
| 403 | Forbidden | all |
| 404 | Not Found | all |
| 405 | Method Not Allowed | all |
| 406 | Not Acceptable | all |
| 407 | Proxy Authentication Required | all |
| 408 | Request Timeout | all |
| 410 | Gone | all |
| 411 | Length Required | all |
| 412 | Precondition Failed | DESCRIBE, SETUP |
| 413 | Request Entity Too Large | all |
| 414 | Request-URI Too Long | all |
| 415 | Unsupported Media Type | all |
| 451 | Invalid parameter | SETUP |
| 452 | Illegal Conference Identifier | SETUP |
| 453 | Not Enough Bandwidth | SETUP |
| 454 | Session Not Found | all |
| 455 | Method Not Valid In This State | all |
| 456 | Header Field Not Valid | all |
| 457 | Invalid Range | PLAY |
| 458 | Parameter Is Read-Only | SET_PARAMETER |
| 459 | Aggregate Operation Not Allowed | all |
| 461 | Unsupported Transport | all |
| 462 | Destination Unreachable | all |
| 500 | Internal Server Error | all |
| 501 | Not Implemented | all |
| 502 | Bad Gateway | all |
| 503 | Service Unavailable | all |
| 504 | Gateway Timeout | all |
| 505 | RTSP Version Not Supported | all |
| 551 | Option not support | all |

*Bảng 1: Các mã trạng thái và việc sử dụng chúng với các phương thức RTSP*

#### 7.1.2 Các trường tiêu đề phản hồi (Response Header Fields)

Các trường response-header cho phép bên nhận yêu cầu truyền thông tin
bổ sung về phản hồi mà không thể đặt trong Status-Line. Các trường
tiêu đề này cung cấp thông tin về máy chủ và về quyền truy cập tiếp
theo vào tài nguyên được xác định bởi Request-URI.

response-header  =     Location             ; Phần 12.25
                    |     Proxy-Authenticate   ; Phần 12.26
                    |     Public               ; Phần 12.28
                    |     Retry-After          ; Phần 12.31
                    |     Server               ; Phần 12.36
                    |     Vary                 ; Phần 12.42
                    |     WWW-Authenticate     ; Phần 12.44

Tên trường response-header chỉ có thể được mở rộng một cách đáng tin
cậy khi kết hợp với việc thay đổi phiên bản giao thức. Tuy nhiên, các
trường tiêu đề mới hoặc mang tính thử nghiệm CÓ THỂ (MAY) được trao
ngữ nghĩa của các trường response-header nếu tất cả các bên trong
giao tiếp đều nhận biết chúng là các trường response-header. Các
trường tiêu đề không được nhận biết sẽ được coi như các trường
entity-header.

## 8 Thực thể (Entity)

Các thông điệp Yêu cầu và Phản hồi CÓ THỂ (MAY) truyền tải một thực
thể nếu không bị hạn chế bởi phương thức yêu cầu hoặc mã trạng thái
phản hồi. Một thực thể bao gồm các trường entity-header và một
entity-body, mặc dù một số phản hồi sẽ chỉ bao gồm các entity-header.

Trong phần này, cả bên gửi và bên nhận đều đề cập đến máy khách hoặc
máy chủ, tùy thuộc vào bên nào gửi và bên nào nhận thực thể.

### 8.1 Các trường tiêu đề thực thể (Entity Header Fields)

Các trường entity-header định nghĩa thông tin meta (metainformation)
tùy chọn về entity-body hoặc, nếu không có thân thông điệp, về tài
nguyên được xác định bởi yêu cầu.

     entity-header       =    Allow               ; Phần 12.4
                         |    Content-Base        ; Phần 12.11
                         |    Content-Encoding    ; Phần 12.12
                         |    Content-Language    ; Phần 12.13
                         |    Content-Length      ; Phần 12.14
                         |    Content-Location    ; Phần 12.15
                         |    Content-Type        ; Phần 12.16
                         |    Expires             ; Phần 12.19
                         |    Last-Modified       ; Phần 12.24
                         |    extension-header
     extension-header    =    message-header

Cơ chế extension-header cho phép các trường entity-header bổ sung
được định nghĩa mà không cần thay đổi giao thức, nhưng các trường này
không thể được giả định là bên nhận sẽ nhận biết được. Các trường
tiêu đề không được nhận biết NÊN (SHOULD) được bên nhận bỏ qua và
được chuyển tiếp bởi các proxy.

### 8.2 Thân thực thể (Entity Body)

Xem [H7.2]

## 9 Các kết nối (Connections)

Các yêu cầu RTSP có thể được truyền theo nhiều cách khác nhau:

- các kết nối truyền tải duy trì liên tục (persistent transport
       connections) được sử dụng cho nhiều giao dịch yêu cầu-phản hồi;
- một kết nối cho mỗi giao dịch yêu cầu/phản hồi;
- chế độ không kết nối (connectionless mode).

Loại kết nối truyền tải được định nghĩa bởi RTSP URI (Phần 3.2). Đối
với lược đồ "rtsp", một kết nối duy trì liên tục được giả định, trong
khi lược đồ "rtspu" yêu cầu các yêu cầu RTSP được gửi mà không cần
thiết lập kết nối.

Không giống như HTTP, RTSP cho phép máy chủ media gửi các yêu cầu tới
máy khách media. Tuy nhiên, điều này chỉ được hỗ trợ đối với các kết
nối duy trì liên tục, vì nếu không máy chủ media sẽ không có cách nào
đáng tin cậy để tiếp cận máy khách. Ngoài ra, đây là cách duy nhất để
các yêu cầu từ máy chủ media tới máy khách có khả năng vượt qua tường
lửa (firewalls).

### 9.1 Pipelining (Kỹ thuật đường ống)

Một máy khách hỗ trợ các kết nối duy trì liên tục hoặc chế độ không
kết nối CÓ THỂ (MAY) "pipeline" các yêu cầu của nó (tức là gửi nhiều
yêu cầu mà không cần đợi từng phản hồi). Một máy chủ PHẢI (MUST) gửi
các phản hồi của nó cho các yêu cầu đó theo đúng thứ tự mà các yêu
cầu đã được nhận.

### 9.2 Độ tin cậy và Xác nhận (Reliability and Acknowledgements)

Các yêu cầu được xác nhận bởi bên nhận trừ khi chúng được gửi tới một
nhóm multicast. Nếu không có xác nhận, bên gửi có thể gửi lại cùng
một thông điệp sau thời gian chờ bằng một thời gian khứ hồi (RTT).
Thời gian khứ hồi được ước tính như trong TCP (RFC 1123) [18], với
giá trị khứ hồi ban đầu là 500 ms. Một bản cài đặt CÓ THỂ (MAY) lưu
vào bộ nhớ đệm kết quả đo RTT gần nhất làm giá trị ban đầu cho các
kết nối tương lai.

Nếu một giao thức truyền tải đáng tin cậy được sử dụng để chuyển tải
RTSP, các yêu cầu KHÔNG ĐƯỢC (MUST NOT) truyền lại; thay vào đó ứng
dụng RTSP PHẢI (MUST) dựa vào lớp truyền tải bên dưới để cung cấp độ
tin cậy.

     Nếu cả tầng truyền tải tin cậy bên dưới như TCP và ứng dụng RTSP
     đều truyền lại các yêu cầu, có khả năng mỗi lần mất gói tin sẽ dẫn
     đến hai lần truyền lại. Bên nhận thường không thể tận dụng việc
     truyền lại ở tầng ứng dụng vì

ngăn xếp truyền tải sẽ không bàn giao gói truyền lại ở tầng ứng
     dụng trước khi lần truyền đầu tiên đến được bên nhận. Nếu việc mất
     gói tin là do tắc nghẽn, việc truyền lại nhiều lần ở các tầng khác
     nhau sẽ làm trầm trọng thêm tình trạng tắc nghẽn.

     Nếu RTSP được sử dụng qua mạng LAN có RTT nhỏ, các thủ tục chuẩn để
     tối ưu hóa ước tính thời gian khứ hồi TCP ban đầu, chẳng hạn như
     những thủ tục được dùng trong T/TCP (RFC 1644) [22], có thể mang
     lại lợi ích.

Tiêu đề Timestamp (Phần 12.38) được sử dụng để tránh vấn đề mơ hồ về
truyền lại [23, tr. 301] và loại bỏ sự cần thiết của thuật toán Karn.

Mỗi yêu cầu mang một số thứ tự trong tiêu đề CSeq (Phần 12.17), số
này được tăng thêm một cho mỗi yêu cầu riêng biệt được truyền đi. Nếu
một yêu cầu được lặp lại do thiếu xác nhận, yêu cầu đó PHẢI (MUST)
mang số thứ tự ban đầu (nghĩa là số thứ tự không được tăng).

Các hệ thống triển khai RTSP PHẢI (MUST) hỗ trợ chuyển tải RTSP qua
TCP và CÓ THỂ (MAY) hỗ trợ UDP. Cổng mặc định cho máy chủ RTSP là 554
cho cả UDP và TCP.

Một số gói RTSP dành cho cùng một điểm cuối điều khiển có thể được
đóng gói vào một PDU tầng thấp hơn duy nhất hoặc được đóng gói vào
một luồng TCP. Dữ liệu RTSP CÓ THỂ (MAY) được xen kẽ (interleaved)
với các gói RTP và RTCP. Không giống như HTTP, một thông điệp RTSP
PHẢI (MUST) chứa tiêu đề Content-Length bất cứ khi nào thông điệp đó
chứa tải trọng (payload). Nếu không, một gói RTSP được kết thúc bằng
một dòng trống ngay sau tiêu đề thông điệp cuối cùng.

## 10 Định nghĩa phương thức (Method Definitions)

Token phương thức chỉ định phương thức được thực hiện trên tài nguyên
được xác định bởi Request-URI. Phương thức có phân biệt chữ hoa chữ
thường (case-sensitive). Các phương thức mới có thể được định nghĩa
trong tương lai. Tên phương thức không được bắt đầu bằng ký tự $
(thập phân 24) và phải là một token. Các phương thức được tóm tắt
trong Bảng 2.

| Phương thức (Method) | Chiều truyền (Direction) | Đối tượng (Object) | Yêu cầu (Requirement) |
| :--- | :--- | :--- | :--- |
| DESCRIBE | C->S | P,S | recommended |
| ANNOUNCE | C->S, S->C | P,S | optional |
| GET_PARAMETER | C->S, S->C | P,S | optional |
| OPTIONS | C->S, S->C | P,S | required <br>(S->C: optional) |
| PAUSE | C->S | P,S | recommended |
| PLAY | C->S | P,S | required |
| RECORD | C->S | P,S | optional |
| REDIRECT | S->C | P,S | optional |
| SETUP | C->S | S | required |
| SET_PARAMETER | C->S, S->C | P,S | optional |
| TEARDOWN | C->S | P,S | required |

*Bảng 2: Tổng quan về các phương thức RTSP, chiều truyền và các đối tượng (P: presentation, S: stream) mà chúng hoạt động*

Ghi chú về Bảng 2: PAUSE được khuyến nghị (recommended), nhưng không
bắt buộc (not required) ở chỗ một máy chủ đầy đủ chức năng vẫn có thể
được xây dựng mà không hỗ trợ phương thức này, ví dụ đối với các
luồng phát trực tiếp (live feeds). Nếu một máy chủ không hỗ trợ một
phương thức cụ thể, nó PHẢI (MUST) trả về "501 Not Implemented" và
máy khách KHÔNG NÊN (SHOULD not) thử lại phương thức này đối với máy
chủ đó.

### 10.1 OPTIONS

Xem [H9.2]. Trạng thái của bản trình chiếu (presentation) hoặc luồng
không nằm trong phản hồi cho yêu cầu OPTIONS. Ngoài ra, một yêu cầu
OPTIONS có thể được gửi sau khi một phiên đã được thiết lập để kiểm
tra tính khả dụng (liveness) của máy chủ. Nếu một máy khách yêu cầu
máy chủ phải hiểu các tùy chọn hoặc phương thức phi tiêu chuẩn,
trường tiêu đề Require (Phần 12.32) PHẢI (MUST) được sử dụng. Nếu máy
chủ không hỗ trợ phần mở rộng này, nó PHẢI (MUST) phản hồi bằng "551
Option not supported". Yêu cầu OPTIONS có thể được đưa ra bất cứ lúc
nào, ví dụ khi máy khách chuẩn bị thử một yêu cầu phi chuẩn. Nó không
ảnh hưởng đến trạng thái của máy chủ.

Ví dụ:

```http
C->S:  OPTIONS * RTSP/1.0
            CSeq: 1
            Require: implicit-play
            Proxy-Require: gzipped-messages

     S->C:  RTSP/1.0 200 OK
            CSeq: 1
            Public: DESCRIBE, SETUP, TEARDOWN, PLAY, PAUSE
```

Lưu ý rằng đây là các tính năng giả định (người ta hy vọng rằng chúng
tôi không cố tình bỏ qua một tính năng thực sự hữu ích chỉ để có một
ví dụ ấn tượng trong phần này).

### 10.2 DESCRIBE

Phương thức DESCRIBE truy xuất mô tả về một bản trình chiếu hoặc đối
tượng media được xác định bởi URL yêu cầu từ một máy chủ. Nó có thể
sử dụng tiêu đề Accept để chỉ định các định dạng mô tả mà máy khách
hiểu được. Máy chủ phản hồi bằng một bản mô tả về tài nguyên được yêu
cầu. Cặp yêu cầu-phản hồi DESCRIBE cấu thành giai đoạn khởi tạo media
của RTSP.

Ví dụ:

```http
C->S: DESCRIBE rtsp://server.example.com/fizzle/foo RTSP/1.0
           CSeq: 312
           Accept: application/sdp, application/rtsl, application/mheg

     S->C: RTSP/1.0 200 OK
           CSeq: 312
           Date: 23 Jan 1997 15:35:06 GMT
           Content-Type: application/sdp
           Content-Length: 376

           v=0
           o=mhandley 2890844526 2890842807 IN IP4 126.16.64.4
           s=SDP Seminar
           i=A Seminar on the session description protocol
           u=http://www.cs.ucl.ac.uk/staff/M.Handley/sdp.03.ps
           e=mjh@isi.edu (Mark Handley)
           c=IN IP4 224.2.17.12/127
           t=2873397496 2873404696
           a=recvonly
           m=audio 3456 RTP/AVP 0
           m=video 2232 RTP/AVP 31
           m=whiteboard 32416 UDP WB
           a=orient:portrait
```

Phản hồi DESCRIBE PHẢI (MUST) chứa tất cả thông tin khởi tạo media
cho (các) tài nguyên mà nó mô tả. Nếu một máy khách media nhận được
mô tả trình chiếu từ một nguồn khác ngoài DESCRIBE và mô tả đó chứa
một tập hợp đầy đủ các tham số khởi tạo media, máy khách NÊN (SHOULD)
sử dụng các tham số đó và không yêu cầu lại mô tả cho cùng một media
qua RTSP.

Ngoài ra, các máy chủ KHÔNG NÊN (SHOULD NOT) sử dụng phản hồi
DESCRIBE như một phương tiện gián tiếp (media indirection).

     Cần thiết lập các quy tắc nền tảng rõ ràng để máy khách có phương
     tiện dứt khoát biết khi nào nên yêu cầu thông tin khởi tạo media
     qua DESCRIBE và khi nào không. Bằng cách buộc phản hồi DESCRIBE

phải chứa tất cả các khởi tạo media cho tập hợp các luồng mà nó mô
     tả, và không khuyến khích việc sử dụng DESCRIBE để gián tiếp chỉ
     định media, chúng ta tránh được các vấn đề lặp vòng (looping) có
     thể phát sinh từ các cách tiếp cận khác.

     Khởi tạo media là một yêu cầu bắt buộc đối với bất kỳ hệ thống nào
     dựa trên RTSP, nhưng đặc tả RTSP không quy định rằng điều này phải
     được thực hiện thông qua phương thức DESCRIBE. Có ba cách để máy
     khách RTSP có thể nhận thông tin khởi tạo:

- qua phương thức DESCRIBE của RTSP;
- qua một số giao thức khác (HTTP, tệp đính kèm email, v.v.);
- qua dòng lệnh hoặc đầu vào tiêu chuẩn (như vậy hoạt động như một
       ứng dụng trợ giúp trình duyệt được khởi chạy với tệp SDP hoặc
       định dạng khởi tạo media khác).

     Vì mục tiêu khả năng tương tác thực tế, rất khuyến nghị rằng các
     máy chủ tối thiểu nên hỗ trợ phương thức DESCRIBE, và rất khuyến
     nghị rằng các máy khách tối thiểu nên hỗ trợ khả năng hoạt động như
     một "ứng dụng trợ giúp" chấp nhận tệp khởi tạo media từ đầu vào
     tiêu chuẩn, dòng lệnh, và/hoặc các phương tiện khác phù hợp với môi
     trường hoạt động của máy khách.

### 10.3 ANNOUNCE

Phương thức ANNOUNCE phục vụ hai mục đích:

Khi được gửi từ máy khách tới máy chủ, ANNOUNCE đăng tải mô tả của
một bản trình chiếu hoặc đối tượng media được xác định bởi URL yêu
cầu lên máy chủ. Khi được gửi từ máy chủ tới máy khách, ANNOUNCE cập
nhật mô tả phiên theo thời gian thực.

Nếu một luồng media mới được thêm vào bản trình chiếu (ví dụ trong
một buổi trình chiếu trực tiếp), toàn bộ bản mô tả trình chiếu nên
được gửi lại, thay vì chỉ gửi các thành phần bổ sung, để các thành
phần cũ có thể bị xóa.

Ví dụ:

```http
C->S: ANNOUNCE rtsp://server.example.com/fizzle/foo RTSP/1.0
           CSeq: 312
           Date: 23 Jan 1997 15:35:06 GMT
           Session: 47112344
           Content-Type: application/sdp
           Content-Length: 332

           v=0
           o=mhandley 2890844526 2890845468 IN IP4 126.16.64.4

s=SDP Seminar
           i=A Seminar on the session description protocol
           u=http://www.cs.ucl.ac.uk/staff/M.Handley/sdp.03.ps
           e=mjh@isi.edu (Mark Handley)
           c=IN IP4 224.2.17.12/127
           t=2873397496 2873404696
           a=recvonly
           m=audio 3456 RTP/AVP 0
           m=video 2232 RTP/AVP 31

     S->C: RTSP/1.0 200 OK
           CSeq: 312
```

### 10.4 SETUP

Yêu cầu SETUP cho một URI chỉ định cơ chế truyền tải sẽ được sử dụng
cho media dạng luồng (streamed media). Một máy khách có thể đưa ra
yêu cầu SETUP cho một luồng đang phát để thay đổi các tham số truyền
tải, điều mà máy chủ CÓ THỂ (MAY) cho phép. Nếu không cho phép điều
này, nó PHẢI (MUST) phản hồi bằng lỗi "455 Method Not Valid In This
State". Để hỗ trợ các tường lửa trung gian, máy khách phải chỉ ra các
tham số truyền tải ngay cả khi nó không có ảnh hưởng gì đối với các
tham số này, chẳng hạn khi máy chủ công bố một địa chỉ multicast cố
định.

     Vì SETUP bao gồm tất cả thông tin khởi tạo truyền tải, các tường
     lửa và các thiết bị mạng trung gian khác (những thiết bị cần thông
     tin này) được miễn nhiệm vụ khó khăn hơn là phân tích cú pháp phản
     hồi DESCRIBE, vốn được dành riêng cho việc khởi tạo media.

Tiêu đề Transport chỉ định các tham số truyền tải mà máy khách chấp
nhận để truyền dữ liệu; phản hồi sẽ chứa các tham số truyền tải do
máy chủ lựa chọn.

```http
C->S: SETUP rtsp://example.com/foo/bar/baz.rm RTSP/1.0
           CSeq: 302
           Transport: RTP/AVP;unicast;client_port=4588-4589

     S->C: RTSP/1.0 200 OK
           CSeq: 302
           Date: 23 Jan 1997 15:35:06 GMT
           Session: 47112344
           Transport: RTP/AVP;unicast;
             client_port=4588-4589;server_port=6256-6257
```

Máy chủ tạo các định danh phiên (session identifiers) để phản hồi các
yêu cầu SETUP. Nếu một yêu cầu SETUP gửi tới máy chủ có chứa một định
danh phiên, máy chủ PHẢI (MUST) gộp yêu cầu thiết lập này vào trong

phiên hiện có hoặc trả về lỗi "459 Aggregate Operation Not Allowed"
(xem Phần 11.3.10).

### 10.5 PLAY

Phương thức PLAY thông báo cho máy chủ bắt đầu gửi dữ liệu qua cơ chế
đã được chỉ định trong SETUP. Máy khách KHÔNG ĐƯỢC (MUST NOT) đưa ra
yêu cầu PLAY cho đến khi bất kỳ yêu cầu SETUP nào chưa hoàn tất đều
đã được xác nhận là thành công.

Yêu cầu PLAY định vị thời gian phát bình thường (NPT) đến đầu khoảng
giá trị được chỉ định và phân phối dữ liệu luồng cho đến khi đạt đến
cuối khoảng giá trị. Các yêu cầu PLAY có thể được nối đường ống (xếp
hàng); máy chủ PHẢI (MUST) xếp hàng các yêu cầu PLAY để thực thi theo
thứ tự. Nói cách khác, một yêu cầu PLAY đến trong khi yêu cầu PLAY
trước đó vẫn đang hoạt động sẽ bị trì hoãn cho đến khi yêu cầu thứ
nhất hoàn tất.

     Điều này cho phép chỉnh sửa chính xác.

Ví dụ, bất kể hai yêu cầu phát trong ví dụ sau đến gần nhau như thế
nào, máy chủ trước tiên sẽ phát giây thứ 10 đến 15 và ngay sau đó,
phát tiếp thời gian phát bình thường từ giây thứ 20 đến 25:

```http
C->S: PLAY rtsp://audio.example.com/audio RTSP/1.0
           CSeq: 835
           Session: 12345678
           Range: npt=10-15

     C->S: PLAY rtsp://audio.example.com/audio RTSP/1.0
           CSeq: 836
           Session: 12345678
           Range: npt=20-25
```

Xem phần mô tả yêu cầu PAUSE để biết thêm các ví dụ.

Một yêu cầu PLAY không có tiêu đề Range là hợp lệ. Nó bắt đầu phát
luồng từ đầu trừ khi luồng đã bị tạm dừng. Nếu luồng đã bị tạm dừng
qua PAUSE, việc phân phối luồng sẽ tiếp tục tại điểm tạm dừng. Nếu
một luồng đang phát, yêu cầu PLAY như vậy sẽ không gây ra thêm hành
động nào và có thể được máy khách dùng để kiểm tra tính khả dụng của
máy chủ.

Tiêu đề Range cũng có thể chứa một tham số time. Tham số này chỉ định
thời gian theo UTC mà tại đó việc phát lại sẽ bắt đầu. Nếu thông điệp
được nhận sau thời gian đã chỉ định, việc phát lại sẽ bắt đầu ngay
lập tức. Tham số time có thể được sử dụng để hỗ trợ đồng bộ hóa các
luồng thu được từ các nguồn khác nhau.

Đối với một luồng theo yêu cầu (on-demand), máy chủ sẽ phản hồi với
khoảng giá trị thực tế sẽ được phát lại. Khoảng này có thể khác với
khoảng được yêu cầu nếu nguồn media yêu cầu căn chỉnh khoảng được yêu
cầu theo ranh giới khung hình (frame boundaries) hợp lệ. Nếu không có
khoảng nào được chỉ định trong yêu cầu, vị trí hiện tại sẽ được trả
về trong phản hồi. Đơn vị của khoảng trong phản hồi giống với đơn vị
trong yêu cầu.

Sau khi phát xong khoảng mong muốn, bản trình chiếu sẽ tự động tạm
dừng, như thể một yêu cầu PAUSE đã được đưa ra.

Ví dụ sau đây phát toàn bộ bản trình chiếu bắt đầu tại mã thời gian
SMPTE 0:10:20 cho đến khi kết thúc clip. Việc phát lại sẽ bắt đầu lúc
15:36 ngày 23 tháng 1 năm 1997.

```http
C->S: PLAY rtsp://audio.example.com/twister.en RTSP/1.0
           CSeq: 833
           Session: 12345678
           Range: smpte=0:10:20-;time=19970123T153600Z

     S->C: RTSP/1.0 200 OK
           CSeq: 833
           Date: 23 Jan 1997 15:35:06 GMT
           Range: smpte=0:10:22-;time=19970123T153600Z
```

Để phát lại một bản ghi của một buổi trình chiếu trực tiếp, việc sử
dụng đơn vị đồng hồ (clock) có thể là mong muốn:

```http
C->S: PLAY rtsp://audio.example.com/meeting.en RTSP/1.0
           CSeq: 835
           Session: 12345678
           Range: clock=19961108T142300Z-19961108T143520Z

     S->C: RTSP/1.0 200 OK
           CSeq: 835
           Date: 23 Jan 1997 15:35:06 GMT
```

Một máy chủ media chỉ hỗ trợ phát lại PHẢI (MUST) hỗ trợ định dạng
npt và CÓ THỂ (MAY) hỗ trợ các định dạng clock và smpte.

### 10.6 PAUSE

Yêu cầu PAUSE làm gián đoạn (tạm dừng) việc phân phối luồng một cách
tạm thời. Nếu URL yêu cầu chỉ định một luồng, chỉ việc phát lại và
ghi của luồng đó bị dừng. Ví dụ đối với âm thanh, điều này tương
đương với việc tắt tiếng (muting). Nếu URL yêu cầu chỉ định một bản
trình chiếu hoặc một nhóm luồng, việc phân phối tất cả các luồng hiện
đang hoạt động trong bản trình chiếu hoặc nhóm đó sẽ bị tạm dừng. Sau
khi tiếp tục phát lại hoặc ghi, việc đồng bộ hóa các track PHẢI
(MUST) được duy trì. Bất kỳ tài nguyên máy chủ nào cũng được giữ
nguyên, mặc dù máy chủ CÓ THỂ (MAY) đóng phiên và giải phóng tài
nguyên sau khi bị tạm dừng trong khoảng thời gian được chỉ định bằng
tham số timeout của tiêu đề Session trong thông điệp SETUP.

Ví dụ:

```http
C->S: PAUSE rtsp://example.com/fizzle/foo RTSP/1.0
           CSeq: 834
           Session: 12345678

     S->C: RTSP/1.0 200 OK
           CSeq: 834
           Date: 23 Jan 1997 15:35:06 GMT
```

Yêu cầu PAUSE có thể chứa một tiêu đề Range chỉ định thời điểm luồng
hoặc bản trình chiếu sẽ bị dừng. Chúng tôi gọi điểm này là "điểm tạm
dừng" (pause point). Tiêu đề phải chứa chính xác một giá trị thay vì
một khoảng thời gian. Thời gian phát bình thường cho luồng được đặt
thành điểm tạm dừng. Yêu cầu tạm dừng có hiệu lực ngay lần đầu tiên
máy chủ gặp điểm thời gian được chỉ định trong bất kỳ yêu cầu PLAY
nào hiện đang chờ xử lý. Nếu tiêu đề Range chỉ định một thời gian nằm
ngoài bất kỳ yêu cầu PLAY nào đang chờ xử lý, lỗi "457 Invalid Range"
sẽ được trả về. Nếu một đơn vị media (chẳng hạn như một khung âm
thanh hoặc video) bắt đầu phát chính xác tại điểm tạm dừng, nó sẽ
không được phát hoặc ghi. Nếu thiếu tiêu đề Range, việc phân phối
luồng sẽ bị ngắt ngay lập tức khi nhận được thông điệp và điểm tạm
dừng được đặt thành thời gian phát bình thường hiện tại.

Yêu cầu PAUSE sẽ hủy bỏ tất cả các yêu cầu PLAY đang xếp hàng. Tuy
nhiên, điểm tạm dừng trong luồng media PHẢI (MUST) được duy trì. Yêu
cầu PLAY tiếp theo không có tiêu đề Range sẽ tiếp tục từ điểm tạm
dừng.

Ví dụ, nếu máy chủ có các yêu cầu phát cho các khoảng từ 10 đến 15 và
20 đến 29 đang chờ xử lý rồi sau đó nhận được yêu cầu tạm dừng cho
NPT 21, nó sẽ bắt đầu phát khoảng thứ hai và dừng tại NPT 21. Nếu yêu
cầu tạm dừng là cho NPT 12 và máy chủ đang phát ở NPT 13 phục vụ yêu
cầu phát đầu tiên, máy chủ sẽ dừng ngay lập tức. Nếu yêu cầu tạm dừng
là cho NPT 16, máy chủ sẽ dừng sau khi hoàn thành

yêu cầu phát đầu tiên và hủy bỏ yêu cầu phát thứ hai.

Một ví dụ khác, nếu một máy chủ đã nhận được các yêu cầu phát các
khoảng từ 10 đến 15 và sau đó từ 13 đến 20 (nghĩa là các khoảng chồng
lấn nhau), yêu cầu PAUSE cho NPT=14 sẽ có hiệu lực trong khi máy chủ
đang phát khoảng đầu tiên, và yêu cầu PLAY thứ hai coi như bị bỏ qua,
giả sử yêu cầu PAUSE đến trước khi máy chủ bắt đầu phát khoảng chồng
lấn thứ hai. Bất kể khi nào yêu cầu PAUSE đến, nó sẽ đặt NPT thành
14.

Nếu máy chủ đã gửi dữ liệu vượt quá thời gian được chỉ định trong
tiêu đề Range, một yêu cầu PLAY vẫn sẽ tiếp tục tại thời điểm đó, vì
giả định rằng máy khách đã loại bỏ dữ liệu sau thời điểm đó. Điều này
đảm bảo chu kỳ tạm dừng/phát diễn ra liên tục không có khoảng trống.

### 10.7 TEARDOWN

Yêu cầu TEARDOWN dừng việc phân phối luồng cho URI đã cho, giải phóng
các tài nguyên liên kết với nó. Nếu URI là URI trình chiếu cho bản
trình chiếu này, mọi định danh phiên RTSP liên kết với phiên đó sẽ
không còn hợp lệ. Trừ khi tất cả các tham số truyền tải đã được xác
định bởi bản mô tả phiên, một yêu cầu SETUP phải được đưa ra trước
khi phiên có thể được phát lại.

Ví dụ:
```http
C->S: TEARDOWN rtsp://example.com/fizzle/foo RTSP/1.0
           CSeq: 892
           Session: 12345678
     S->C: RTSP/1.0 200 OK
           CSeq: 892
```

### 10.8 GET_PARAMETER

Yêu cầu GET_PARAMETER truy xuất giá trị của một tham số của bản trình
chiếu hoặc luồng được chỉ định trong URI. Nội dung của phản hồi được
dành cho bản cài đặt tự định nghĩa. GET_PARAMETER không có thân thực
thể (entity body) có thể được sử dụng để kiểm tra tính khả dụng của
máy khách hoặc máy chủ ("ping").

Ví dụ:

```http
S->C: GET_PARAMETER rtsp://example.com/fizzle/foo RTSP/1.0
           CSeq: 431
           Content-Type: text/parameters
           Session: 12345678
           Content-Length: 15

           packets_received
           jitter

C->S: RTSP/1.0 200 OK
           CSeq: 431
           Content-Length: 46
           Content-Type: text/parameters

           packets_received: 10
           jitter: 0.3838
```

Ví dụ "ping":

```http
S->C: GET_PARAMETER rtsp://example.com/fizzle/foo RTSP/1.0
           CSeq: 432

     C->S: RTSP/1.0 200 OK
           CSeq: 432
           Content-Type: text/parameters
           Content-Length: 0
```

### 10.9 SET_PARAMETER

Phương thức này yêu cầu thiết lập giá trị của một tham số cho một bản
trình chiếu hoặc luồng được chỉ định bởi URI.

Một yêu cầu NÊN (SHOULD) chỉ chứa một tham số duy nhất để cho phép
máy khách xác định lý do tại sao một tham số cụ thể không thể được
thiết lập. Nếu yêu cầu chứa nhiều tham số, máy chủ CHỈ ĐƯỢC (MUST
only) thực hiện yêu cầu nếu tất cả các tham số đều có thể được thiết
lập thành công. Một máy chủ PHẢI (MUST) cho phép một SET_PARAMETER
không có nội dung để kiểm tra kết nối và tính khả dụng của máy khách
hoặc máy chủ ("ping").

Ví dụ:

```http
C->S: SET_PARAMETER rtsp://example.com/fizzle/foo RTSP/1.0
           CSeq: 421
           Content-length: 20
           Content-type: text/parameters

           bar: barval

     S->C: RTSP/1.0 451 Invalid Parameter
           CSeq: 421
           Content-length: 10
           Content-type: text/parameters

           bar
```

Phản hồi 451 (Invalid Parameter) cũng có thể trả về một danh sách các
tham số không thể thiết lập được.

### 10.10 REDIRECT

Yêu cầu REDIRECT thông báo cho máy khách rằng nó phải kết nối tới một
vị trí máy chủ khác. Nó chứa tiêu đề bắt buộc Location, chỉ định rằng
máy khách nên đưa ra các yêu cầu cho URL hoặc bản trình chiếu đó tới
máy chủ mới. Tham số Range có thể được sử dụng để chỉ định thời điểm
việc chuyển hướng có hiệu lực. Nếu máy khách muốn tiếp tục gửi hoặc
nhận media cho URI này, máy khách PHẢI (MUST) đưa ra một yêu cầu
TEARDOWN cho phiên hiện tại và một yêu cầu SETUP cho phiên mới tại
máy chủ được chỉ định.

Ví dụ:

```http
S->C: REDIRECT rtsp://example.com/fizzle/foo RTSP/1.0
           CSeq: 732
           Location: rtsp://bigserver.com:8001
           Range: clock=19961108T142300Z
```

### 10.11 RECORD

Phương thức này khởi tạo việc ghi lại một khoảng dữ liệu media theo
mô tả bản trình chiếu. Dấu thời gian phản ánh thời gian bắt đầu và
kết thúc (UTC). Nếu không có khoảng thời gian nào được đưa ra, hãy sử
dụng thời gian bắt đầu hoặc kết thúc được cung cấp trong bản mô tả
trình chiếu. Nếu phiên đã bắt đầu, hãy tiến hành ghi ngay lập tức.

Máy chủ quyết định việc lưu trữ dữ liệu được ghi dưới request-URI hay
một URI khác. Nếu máy chủ không sử dụng request-URI, phản hồi NÊN
(SHOULD) là 201 (Created) và chứa một thực thể mô tả trạng thái của
yêu cầu và tham chiếu đến tài nguyên mới, cùng với một tiêu đề
Location.

Một máy chủ media hỗ trợ ghi các bản trình chiếu trực tiếp PHẢI
(MUST) hỗ trợ định dạng khoảng clock; định dạng smpte không có ý
nghĩa đối với các bản trình chiếu trực tiếp.

Trong ví dụ này, máy chủ media trước đó đã được mời tham gia vào hội
nghị được chỉ định.

```http
C->S: RECORD rtsp://example.com/meeting/audio.en RTSP/1.0
           CSeq: 954
           Session: 12345678
           Conference: 128.16.64.19/32492374
```

### 10.12 Dữ liệu nhị phân nhúng (xen kẽ) - Embedded Binary Data

Một số thiết kế tường lửa nhất định và các hoàn cảnh khác có thể buộc
máy chủ phải xen kẽ các phương thức RTSP và dữ liệu luồng. Việc xen
kẽ này nhìn chung nên tránh trừ khi thực sự cần thiết vì nó làm phức
tạp hoạt động của máy khách và máy chủ cũng như tạo thêm chi phí phụ
tải (overhead). Dữ liệu nhị phân xen kẽ CHỈ NÊN (SHOULD only) được sử
dụng nếu RTSP được truyền tải qua TCP.

Dữ liệu luồng như các gói tin RTP được đóng gói bằng một dấu đô la
ASCII ($ - giá trị thập lục phân 24), tiếp theo là một byte định danh
kênh (channel identifier), theo sau bởi độ dài của dữ liệu nhị phân
được đóng gói dưới dạng số nguyên nhị phân 2 byte theo thứ tự byte
mạng (network byte order). Dữ liệu luồng theo sau ngay sau đó, không
có CRLF, nhưng bao gồm các tiêu đề giao thức tầng trên. Mỗi khối $
chứa chính xác một đơn vị dữ liệu giao thức (PDU) tầng trên, ví dụ
một gói RTP.

Định danh kênh được xác định trong tiêu đề Transport với tham số
interleaved (Phần 12.39).

Khi lựa chọn truyền tải là RTP, các thông điệp RTCP cũng được máy chủ
xen kẽ qua kết nối TCP. Theo mặc định, các gói RTCP được gửi trên
kênh khả dụng đầu tiên cao hơn kênh RTP. Máy khách CÓ THỂ (MAY) yêu
cầu rõ ràng các gói RTCP trên một kênh khác. Điều này được thực hiện
bằng cách chỉ định hai kênh trong tham số interleaved của tiêu đề
Transport (Phần 12.39).

     RTCP là cần thiết để đồng bộ hóa khi có từ hai luồng trở lên được
     xen kẽ theo cách như vậy. Ngoài ra, điều này cung cấp một cách
     thuận tiện để tạo đường hầm (tunnel) cho các gói RTP/RTCP qua kết
     nối điều khiển TCP khi cấu hình mạng yêu cầu và chuyển chúng sang
     UDP khi có thể.

```http
C->S: SETUP rtsp://foo.com/bar.file RTSP/1.0
           CSeq: 2
           Transport: RTP/AVP/TCP;interleaved=0-1

     S->C: RTSP/1.0 200 OK
           CSeq: 2
           Date: 05 Jun 1997 18:57:18 GMT
           Transport: RTP/AVP/TCP;interleaved=0-1

Session: 12345678

     C->S: PLAY rtsp://foo.com/bar.file RTSP/1.0
           CSeq: 3
           Session: 12345678

     S->C: RTSP/1.0 200 OK
           CSeq: 3
           Session: 12345678
           Date: 05 Jun 1997 18:59:15 GMT
           RTP-Info: url=rtsp://foo.com/bar.file;
             seq=232433;rtptime=972948234

     S->C: $ {độ dài 2 byte}{"length" byte dữ liệu, kèm RTP header}
     S->C: $ {độ dài 2 byte}{"length" byte dữ liệu, kèm RTP header}
     S->C: ${độ dài 2 byte}{"length" byte gói tin RTCP}
```

## 11 Định nghĩa mã trạng thái (Status Code Definitions)

Khi có thể áp dụng, các mã trạng thái HTTP [H10] được tái sử dụng.
Các mã trạng thái có cùng ý nghĩa không được lặp lại ở đây. Xem Bảng
1 để biết danh sách mã trạng thái nào có thể được trả về bởi yêu cầu
nào.

### 11.1 Thành công (Success) 2xx

11.1.1 250 Sắp hết dung lượng lưu trữ (Low on Storage Space)

Máy chủ trả về cảnh báo này sau khi nhận được yêu cầu RECORD mà nó có
thể không đáp ứng trọn vẹn do không đủ dung lượng lưu trữ. Nếu có
thể, máy chủ nên sử dụng tiêu đề Range để chỉ ra khoảng thời gian mà
nó vẫn có thể ghi được. Do các tiến trình khác trên máy chủ có thể
đang đồng thời tiêu thụ dung lượng lưu trữ, máy khách chỉ nên coi đây
là một ước tính.

### 11.2 Chuyển hướng (Redirection) 3xx

Xem [H10.3].

Trong RTSP, chuyển hướng có thể được sử dụng để cân bằng tải hoặc
chuyển hướng các yêu cầu luồng đến máy chủ gần hơn về mặt topo mạng
đối với máy khách. Các cơ chế để xác định khoảng cách topo mạng nằm
ngoài phạm vi của đặc tả này.

### 11.3 Lỗi máy khách (Client Error) 4xx

11.3.1 405 Phương thức không được phép (Method Not Allowed)

Phương thức được chỉ định trong yêu cầu không được phép đối với tài
nguyên được xác định bởi URI yêu cầu. Phản hồi PHẢI (MUST) bao gồm
tiêu đề Allow chứa danh sách các phương thức hợp lệ cho tài nguyên
được yêu cầu. Mã trạng thái này cũng được sử dụng nếu một yêu cầu cố
gắng sử dụng một phương thức không được chỉ định trong SETUP, ví dụ
nếu yêu cầu RECORD được đưa ra mặc dù tham số mode trong tiêu đề
Transport chỉ chỉ định PLAY.

11.3.2 451 Không hiểu tham số (Parameter Not Understood)

Bên nhận yêu cầu không hỗ trợ một hoặc nhiều tham số có trong yêu
cầu.

11.3.3 452 Không tìm thấy hội nghị (Conference Not Found)

Hội nghị được chỉ định bởi trường tiêu đề Conference không được biết
đối với máy chủ media.

11.3.4 453 Không đủ băng thông (Not Enough Bandwidth)

Yêu cầu bị từ chối vì không đủ băng thông. Ví dụ, điều này có thể là
kết quả của một thất bại khi đặt trước tài nguyên (resource
reservation).

11.3.5 454 Không tìm thấy phiên (Session Not Found)

Định danh phiên RTSP trong tiêu đề Session bị thiếu, không hợp lệ
hoặc đã hết thời gian chờ (timed out).

11.3.6 455 Phương thức không hợp lệ ở trạng thái này (Method Not Valid in This State)

Máy khách hoặc máy chủ không thể xử lý yêu cầu này ở trạng thái hiện
tại của nó. Phản hồi NÊN (SHOULD) chứa một tiêu đề Allow để giúp việc
phục hồi lỗi dễ dàng hơn.

11.3.7 456 Trường tiêu đề không hợp lệ cho tài nguyên (Header Field Not Valid for Resource)

Máy chủ không thể thực hiện theo một tiêu đề yêu cầu bắt buộc. Ví dụ,
nếu PLAY chứa trường tiêu đề Range nhưng luồng không cho phép tua
(seeking).

11.3.8 457 Khoảng giá trị không hợp lệ (Invalid Range)

Giá trị Range được đưa ra nằm ngoài giới hạn, ví dụ vượt quá điểm kết
thúc của bản trình chiếu.

11.3.9 458 Tham số chỉ đọc (Parameter Is Read-Only)

Tham số được thiết lập bởi SET_PARAMETER có thể đọc nhưng không thể
sửa đổi.

11.3.10 459 Không cho phép thao tác tổng hợp (Aggregate Operation Not Allowed)

Phương thức được yêu cầu không thể được áp dụng trên URL đang xét vì
đó là một URL tổng hợp (bản trình chiếu). Phương thức này có thể được
áp dụng trên một URL luồng đơn lẻ.

11.3.11 460 Chỉ cho phép thao tác tổng hợp (Only Aggregate Operation Allowed)

Phương thức được yêu cầu không thể được áp dụng trên URL đang xét vì
đó không phải là một URL tổng hợp (bản trình chiếu). Phương thức này
có thể được áp dụng trên URL bản trình chiếu.

11.3.12 461 Giao thức truyền tải không được hỗ trợ (Unsupported Transport)

Trường Transport không chứa một đặc tả truyền tải được hỗ trợ.

11.3.13 462 Không thể đến được đích (Destination Unreachable)

Kênh truyền dữ liệu không thể được thiết lập vì không thể kết nối tới
địa chỉ của máy khách. Lỗi này rất có thể là kết quả của việc máy
khách cố gắng đặt một tham số Destination không hợp lệ vào trường
Transport.

11.3.14 551 Tùy chọn không được hỗ trợ (Option not supported)

Một tùy chọn được đưa ra trong các trường Require hoặc Proxy-Require
không được hỗ trợ. Tiêu đề Unsupported nên được trả về nêu rõ tùy
chọn không có sự hỗ trợ.

## 12 Định nghĩa các trường tiêu đề (Header Field Definitions)

HTTP/1.1 [2] hoặc các trường tiêu đề không chuẩn khác không được liệt
kê ở đây hiện không có ý nghĩa được xác định rõ ràng và NÊN bị người
nhận bỏ qua.

Bảng 3 tóm tắt các trường tiêu đề được RTSP sử dụng. Loại "g" chỉ
định các tiêu đề yêu cầu chung được tìm thấy trong cả yêu cầu và phản
hồi, loại "R" chỉ định các tiêu đề yêu cầu, loại "r" chỉ định các
tiêu đề phản hồi và loại "e" chỉ định các trường tiêu đề thực thể.
Các trường được đánh dấu bằng "req." trong cột có nhãn "hỗ trợ" PHẢI
được người nhận triển khai cho một phương thức cụ thể, trong khi các
trường được đánh dấu là "opt". là tùy chọn. Lưu ý rằng không phải tất
cả các trường đều được đánh dấu "req." sẽ được gửi trong mọi yêu cầu
thuộc loại này. "yêu cầu." chỉ có nghĩa là máy khách (đối với tiêu đề
phản hồi) và máy chủ (đối với tiêu đề yêu cầu) PHẢI triển khai các
trường. Cột cuối cùng liệt kê phương thức mà trường tiêu đề này có ý
nghĩa; ký hiệu "thực thể" đề cập đến tất cả các phương thức trả về
nội dung thư. Trong đặc tả này, DESCRIBE và GET_PARAMETER thuộc lớp
này.

| Trường tiêu đề (Header Field) | Loại (Type) | Mức hỗ trợ (Support) | Phương thức áp dụng (Methods) |
| :--- | :--- | :--- | :--- |
| Accept | R | opt. | entity |
| Accept-Encoding | R | opt. | entity |
| Accept-Language | R | opt. | all |
| Allow | r | opt. | all |
| Authorization | R | opt. | all |
| Bandwidth | R | opt. | all |
| Blocksize | R | opt. | all but OPTIONS, TEARDOWN |
| Cache-Control | g | opt. | SETUP |
| Conference | R | opt. | SETUP |
| Connection | g | req. | all |
| Content-Base | e | opt. | entity |
| Content-Encoding | e | req. | SET_PARAMETER |
| Content-Encoding | e | req. | DESCRIBE, ANNOUNCE |
| Content-Language | e | req. | DESCRIBE, ANNOUNCE |
| Content-Length | e | req. | SET_PARAMETER, ANNOUNCE |
| Content-Length | e | req. | entity |
| Content-Location | e | opt. | entity |
| Content-Type | e | req. | SET_PARAMETER, ANNOUNCE |
| Content-Type | r | req. | entity |
| CSeq | g | req. | all |
| Date | g | opt. | all |
| Expires | e | opt. | DESCRIBE, ANNOUNCE |
| From | R | opt. | all |
| If-Modified-Since | R | opt. | DESCRIBE, SETUP |
| Last-Modified | e | opt. | entity |
| Proxy-Authenticate | | | |
| Proxy-Require | R | req. | all |
| Public | r | opt. | all |
| Range | R | opt. | PLAY, PAUSE, RECORD |
| Range | r | opt. | PLAY, PAUSE, RECORD |
| Referer | R | opt. | all |
| Require | R | req. | all |
| Retry-After | r | opt. | all |
| RTP-Info | r | req. | PLAY |
| Scale | Rr | opt. | PLAY, RECORD |
| Session | Rr | req. | all but SETUP, OPTIONS |
| Server | r | opt. | all |
| Speed | Rr | opt. | PLAY |
| Transport | Rr | req. | SETUP |
| Unsupported | r | req. | all |
| User-Agent | R | opt. | all |
| Via | g | opt. | all |
| WWW-Authenticate | r | opt. | all |

*Bảng 3: Tổng quan về các trường tiêu đề RTSP (Table 3: Overview of RTSP header fields)*

### 12.1 Accept

Trường tiêu đề yêu cầu Chấp nhận có thể được sử dụng để chỉ định một
số loại nội dung mô tả bản trình bày nhất định được chấp nhận cho
phản hồi.

     Tham số "cấp độ" cho mô tả bản trình bày được xác định chính xác
     như một phần của đăng ký loại MIME, không phải ở đây.

Xem [H14.1] để biết cú pháp.

Example of use:
     Accept: application/rtsl, application/sdp;level=2

### 12.2 Accept-Encoding

     Xem [H14.3]

### 12.3 Accept-Language

Xem [H14.4]. Lưu ý rằng ngôn ngữ được chỉ định áp dụng cho mô tả bản
trình bày và bất kỳ cụm từ lý do nào, không phải nội dung phương
tiện.

### 12.4 Allow

Trường tiêu đề Cho phép phản hồi liệt kê các phương thức được hỗ trợ
bởi tài nguyên được xác định bởi URI yêu cầu. Mục đích của trường này
là thông báo nghiêm ngặt cho người nhận về các phương thức hợp lệ
được liên kết với tài nguyên. Trường tiêu đề Cho phép phải xuất hiện
trong phản hồi 405 (Phương thức không được phép).

Example of use:
     Allow: SETUP, PLAY, RECORD, SET_PARAMETER

### 12.5 Authorization

     Xem [H14.8]

### 12.6 Bandwidth

Trường tiêu đề yêu cầu băng thông mô tả băng thông ước tính có sẵn
cho máy khách, được biểu thị dưới dạng số nguyên dương và được đo
bằng bit trên giây. Băng thông có sẵn cho máy khách có thể thay đổi
trong phiên RTSP, ví dụ: do đào tạo lại modem.

Bandwidth = "Bandwidth" ":" 1*DIGIT

Example:
     Bandwidth: 4000

### 12.7 Blocksize

Trường tiêu đề yêu cầu này được gửi từ máy khách đến máy chủ phương
tiện để yêu cầu máy chủ cung cấp kích thước gói phương tiện cụ thể.
Kích thước gói này không bao gồm các tiêu đề lớp thấp hơn như IP, UDP
hoặc RTP. Máy chủ có thể tự do sử dụng kích thước khối thấp hơn kích
thước khối được yêu cầu. Máy chủ CÓ THỂ cắt bớt kích thước gói này
thành bội số gần nhất của kích thước khối tối thiểu dành riêng cho
phương tiện hoặc ghi đè nó bằng kích thước dành riêng cho phương tiện
nếu cần. Kích thước khối PHẢI là số thập phân dương, được đo bằng
octet. Máy chủ chỉ trả về lỗi (416) nếu giá trị cú pháp không hợp lệ.

### 12.8 Cache-Control

Trường tiêu đề chung Kiểm soát bộ đệm được sử dụng để chỉ định các
lệnh PHẢI được tuân theo bởi tất cả các cơ chế bộ nhớ đệm dọc theo
chuỗi yêu cầu/phản hồi.

Các chỉ thị bộ đệm phải được chuyển qua ứng dụng proxy hoặc cổng, bất
kể tầm quan trọng của chúng đối với ứng dụng đó vì các lệnh này có
thể áp dụng cho tất cả người nhận dọc theo chuỗi yêu cầu/phản hồi.
Không thể chỉ định chỉ thị cache cho một cache cụ thể.

Kiểm soát bộ đệm chỉ nên được chỉ định trong yêu cầu THIẾT LẬP và
phản hồi của nó. Lưu ý: Kiểm soát bộ đệm không quản lý việc lưu vào
bộ nhớ đệm của các phản hồi như đối với HTTP mà quản lý luồng được
xác định bởi yêu cầu CÀI ĐẶT. Các phản hồi cho các yêu cầu RTSP không
được lưu vào bộ nhớ đệm, ngoại trừ các phản hồi cho DESCRIBE.

Cache-Control            =   "Cache-Control" ":" 1#cache-directive
cache-directive          =   cache-request-directive
                            |   cache-response-directive
cache-request-directive  =   "no-cache"
                            |   "max-stale"
                            |   "min-fresh"
                            |   "only-if-cached"
                            |   cache-extension
cache-response-directive =   "public"
                            |   "private"
                            |   "no-cache"
                            |   "no-transform"
                            |   "must-revalidate"

|   "proxy-revalidate"
                            |   "max-age" "=" delta-seconds
                            |   cache-extension
cache-extension          =   token [ "=" ( token | quoted-string ) ]

- **no-cache:**
  Cho biết luồng phương tiện KHÔNG được lưu vào bộ nhớ đệm ở bất
  kỳ đâu. Điều này cho phép máy chủ gốc ngăn chặn việc lưu vào
  bộ nhớ đệm ngay cả đối với các bộ nhớ đệm đã được định cấu
  hình để trả về các phản hồi cũ cho các yêu cầu của máy khách.

- **public:**
  Cho biết luồng phương tiện có thể được lưu vào bộ đệm bởi bất
  kỳ bộ đệm nào.

- **private:**
  Cho biết luồng phương tiện được dành cho một người dùng và
  KHÔNG ĐƯỢC lưu vào bộ nhớ đệm bằng bộ nhớ đệm dùng chung. Bộ
  nhớ đệm riêng tư (không chia sẻ) có thể lưu vào bộ nhớ đệm
  luồng phương tiện.

- **no-transform:**
  Bộ đệm trung gian (proxy) có thể hữu ích khi chuyển đổi loại
  phương tiện của một luồng nhất định. Ví dụ: một proxy có thể
  chuyển đổi giữa các định dạng video để tiết kiệm dung lượng bộ
  nhớ đệm hoặc giảm lượng lưu lượng truy cập trên một liên kết
  chậm. Tuy nhiên, các vấn đề vận hành nghiêm trọng có thể xảy
  ra khi những chuyển đổi này được áp dụng cho các luồng dành
  cho một số loại ứng dụng nhất định. Ví dụ: các ứng dụng chụp
  ảnh y tế, phân tích dữ liệu khoa học và những ứng dụng sử dụng
  xác thực đầu cuối đều phụ thuộc vào việc nhận luồng giống hệt
  từng bit với nội dung thực thể ban đầu. Do đó, nếu phản hồi
  bao gồm lệnh không chuyển đổi thì bộ đệm hoặc proxy trung gian
  KHÔNG PHẢI thay đổi mã hóa của luồng. Không giống như HTTP,
  RTSP không cung cấp khả năng chuyển đổi một phần tại thời điểm
  này, ví dụ: cho phép dịch sang ngôn ngữ khác.

- **only-if-cached:**
  Trong một số trường hợp, chẳng hạn như thời điểm kết nối mạng
  cực kỳ kém, máy khách có thể muốn bộ đệm chỉ trả về những
  luồng phương tiện mà nó hiện đã lưu trữ và không nhận những
  luồng này từ máy chủ gốc. Để thực hiện việc này, máy khách có
  thể bao gồm chỉ thị only-if-cache trong một yêu cầu. Nếu nhận
  được lệnh này, bộ nhớ đệm NÊN phản hồi bằng cách sử dụng luồng
  phương tiện được lưu trong bộ nhớ đệm phù hợp với các ràng
  buộc khác của yêu cầu hoặc phản hồi với trạng thái 504 (Hết
  thời gian cổng). Tuy nhiên, nếu một nhóm bộ đệm đang được vận
  hành như một hệ thống thống nhất có kết nối nội bộ tốt thì yêu
  cầu đó CÓ THỂ được chuyển tiếp trong nhóm bộ đệm đó.

max-stale:
          Cho biết rằng máy khách sẵn sàng chấp nhận luồng phương tiện
          đã vượt quá thời gian hết hạn. Nếu max-stale được gán một giá
          trị thì máy khách sẵn sàng chấp nhận phản hồi vượt quá thời
          gian hết hạn không quá số giây được chỉ định. Nếu không có giá
          trị nào được gán cho max-stale thì khách hàng sẵn sàng chấp
          nhận phản hồi cũ ở mọi lứa tuổi.

- **min-fresh:**
  Cho biết rằng khách hàng sẵn sàng chấp nhận luồng phương tiện
  có thời gian làm mới không nhỏ hơn tuổi hiện tại cộng với thời
  gian được chỉ định tính bằng giây. Nghĩa là, khách hàng muốn
  một phản hồi vẫn mới trong ít nhất số giây được chỉ định.

- **must-revalidate:**
  Khi chỉ thị phải xác nhận lại xuất hiện trong phản hồi THIẾT
  LẬP mà bộ đệm nhận được, bộ đệm đó KHÔNG PHẢI sử dụng mục nhập
  sau khi nó trở nên cũ để phản hồi yêu cầu tiếp theo mà không
  xác thực lại nó với máy chủ gốc trước. Nghĩa là, bộ đệm phải
  thực hiện xác nhận lại từ đầu đến cuối mỗi lần, nếu chỉ dựa
  vào Hết hạn của máy chủ gốc, phản hồi được lưu trong bộ nhớ
  đệm đã cũ.)

### 12.9 Conference

Trường tiêu đề yêu cầu này thiết lập kết nối logic giữa hội nghị được
thiết lập trước và luồng RTSP. Không được thay đổi id hội nghị cho
cùng một phiên RTSP.

Conference = "Conference" ":" conference-id Example:
     Conference: 199702170042.SAA08642@obiwan.arl.wustl.edu%20Starr

Mã phản hồi 452 (Không tìm thấy hội nghị 452) được trả về nếu id hội
nghị không hợp lệ.

### 12.10 Connection

Xem [H14.10]

### 12.11 Content-Base

Xem [H14.11]

### 12.12 Content-Encoding

Xem [H14.12]

### 12.13 Content-Language

Xem [H14.13]

### 12.14 Content-Length

Trường này chứa độ dài nội dung của phương thức (tức là sau CRLF kép
theo tiêu đề cuối cùng). Không giống như HTTP, nó PHẢI được bao gồm
trong tất cả các tin nhắn mang nội dung ngoài phần tiêu đề của tin
nhắn. Nếu nó bị thiếu, giá trị mặc định là 0 được giả sử. Nó được
diễn giải theo [H14.14].

### 12.15 Content-Location

Xem [H14.15]

### 12.16 Content-Type

Xem [H14.18]. Lưu ý rằng các loại nội dung phù hợp với RTSP có thể bị
hạn chế trong thực tế ở các mô tả trình bày và các loại giá trị tham
số.

### 12.17 CSeq

Trường CSeq chỉ định số thứ tự cho cặp yêu cầu-phản hồi RTSP. Trường
này PHẢI có mặt trong tất cả các yêu cầu và phản hồi. Đối với mọi yêu
cầu RTSP chứa số thứ tự đã cho, sẽ có phản hồi tương ứng có cùng số
đó. Mọi yêu cầu được truyền lại phải chứa cùng số thứ tự với yêu cầu
ban đầu (tức là số thứ tự không được tăng lên khi truyền lại cùng một
yêu cầu).

### 12.18 Date

Xem [H14.19].

### 12.19 Expires

Trường tiêu đề thực thể Hết hạn cung cấp ngày và giờ mà sau đó mô tả
hoặc luồng phương tiện sẽ được coi là cũ. Việc giải thích phụ thuộc
vào phương pháp:

Phản hồi MÔ TẢ: Tiêu đề Hết hạn cho biết ngày và giờ mà sau đó mô tả
sẽ được coi là cũ.

Mục nhập bộ đệm cũ thường không được bộ đệm (bộ đệm proxy hoặc bộ đệm
tác nhân người dùng) trả về trừ khi nó được xác thực lần đầu với máy
chủ gốc (hoặc với bộ đệm trung gian có bản sao mới của thực thể). Xem
phần 13 để thảo luận thêm về mô hình hết hạn.

Sự hiện diện của trường Hết hạn không có nghĩa là tài nguyên ban đầu
sẽ thay đổi hoặc ngừng tồn tại tại, trước hoặc sau thời điểm đó.

Định dạng là ngày và giờ tuyệt đối được xác định bởi HTTP-date trong
[H3.3]; nó PHẢI ở định dạng ngày RFC1123:

Expires = "Expires" ":" HTTP-date

Một ví dụ về việc sử dụng nó là

     Hết hạn: Thứ năm, ngày 01 tháng 12 năm 1994 16:00:00 GMT

Máy khách và bộ đệm RTSP/1.0 PHẢI xử lý các định dạng ngày không hợp
lệ khác, đặc biệt bao gồm giá trị "0", như đã xảy ra trong quá khứ
(tức là "đã hết hạn").

Để đánh dấu phản hồi là "đã hết hạn", máy chủ gốc phải sử dụng Ngày
hết hạn bằng với giá trị tiêu đề Ngày. Để đánh dấu phản hồi là "không
bao giờ hết hạn", máy chủ gốc phải sử dụng ngày Hết hạn khoảng một
năm kể từ thời điểm phản hồi được gửi. Máy chủ RTSP/1.0 không được
gửi ngày hết hạn quá một năm trong tương lai.

Sự hiện diện của trường tiêu đề Hết hạn có giá trị ngày ở một thời
điểm nào đó trong tương lai trên luồng phương tiện mà theo mặc định
sẽ không thể lưu vào bộ đệm cho biết rằng luồng phương tiện có thể
lưu vào bộ đệm, trừ khi được trường tiêu đề Kiểm soát bộ nhớ đệm chỉ
định khác (Phần 12.8).

### 12.20 From

Xem [H14.22].

### 12.21 Host

Trường tiêu đề yêu cầu HTTP này không cần thiết cho RTSP. Nó nên được
âm thầm bỏ qua nếu được gửi.

### 12.22 If-Match

Xem [H14.25].

Trường này đặc biệt hữu ích để đảm bảo tính toàn vẹn của mô tả bản
trình bày, trong cả trường hợp nó được tìm nạp thông qua các phương
tiện bên ngoài RTSP (chẳng hạn như HTTP) hoặc trong trường hợp việc
triển khai máy chủ đang đảm bảo tính toàn vẹn của mô tả giữa thời
gian của thông báo MÔ TẢ và thông báo THIẾT LẬP.

Mã định danh là mã định danh không rõ ràng và do đó không dành riêng
cho bất kỳ ngôn ngữ mô tả phiên cụ thể nào.

### 12.23 If-Modified-Since

Trường tiêu đề yêu cầu If-Modified-Since được sử dụng cùng với các
phương thức DESCRIBE và SETUP để biến chúng thành điều kiện. Nếu biến
thể được yêu cầu chưa được sửa đổi kể từ thời điểm được chỉ định
trong trường này, thì mô tả sẽ không được trả về từ máy chủ (MÔ TẢ)
hoặc luồng sẽ không được thiết lập (CÀI ĐẶT). Thay vào đó, phản hồi
304 (không được sửa đổi) sẽ được trả về mà không có bất kỳ nội dung
thư nào.

If-Modified-Since = "If-Modified-Since" ":" HTTP-date

Một ví dụ về lĩnh vực này là:

     Nếu-Đã sửa đổi-Kể từ: Thứ bảy, ngày 29 tháng 10 năm 1994 19:43:31
     GMT

### 12.24 Last-Modified

Trường tiêu đề thực thể được sửa đổi lần cuối cho biết ngày và giờ mà
máy chủ gốc tin rằng mô tả bản trình bày hoặc luồng phương tiện được
sửa đổi lần cuối. Xem [H14.29]. Đối với các phương thức MÔ TẢ hoặc
THÔNG BÁO, trường tiêu đề cho biết ngày và giờ sửa đổi cuối cùng của
mô tả, đối với THIẾT LẬP của luồng phương tiện.

### 12.25 Location

Xem [H14.30].

### 12.26 Proxy-Authenticate

Xem [H14.33].

### 12.27 Proxy-Require

Tiêu đề Proxy-Require được sử dụng để biểu thị các tính năng nhạy cảm
với proxy PHẢI được proxy hỗ trợ. Bất kỳ tính năng tiêu đề Yêu cầu
Proxy nào không được proxy hỗ trợ PHẢI được proxy xác nhận tiêu cực
đối với máy khách nếu không được hỗ trợ. Máy chủ

nên xử lý trường này giống hệt với trường Yêu cầu.

Xem Phần 12.32 để biết thêm chi tiết về cơ chế của thông báo này và
ví dụ sử dụng.

### 12.28 Public

Xem [H14.35].

### 12.29 Range

Trường tiêu đề yêu cầu và phản hồi này chỉ định một khoảng thời gian.
Phạm vi có thể được chỉ định trong một số đơn vị. Thông số kỹ thuật
này xác định các đơn vị phạm vi smpte (Phần 3.5), npt (Phần 3.6) và
đồng hồ (Phần 3.7). Trong RTSP, phạm vi byte [H14.36.1] không có ý
nghĩa và KHÔNG PHẢI được sử dụng. Tiêu đề cũng có thể chứa tham số
thời gian trong UTC, chỉ định thời điểm mà hoạt động sẽ có hiệu lực.
Các máy chủ hỗ trợ tiêu đề Phạm vi PHẢI hiểu định dạng phạm vi NPT và
NÊN hiểu định dạng phạm vi SMPTE. Tiêu đề phản hồi Phạm vi cho biết
khoảng thời gian thực sự được phát hoặc ghi. Nếu tiêu đề Phạm vi được
đưa ra ở định dạng thời gian không được hiểu thì người nhận sẽ trả về
"501 Chưa được triển khai".

Phạm vi là các khoảng nửa mở, bao gồm điểm dưới nhưng không bao gồm
điểm trên. Nói cách khác, phạm vi a-b bắt đầu chính xác tại thời điểm
a, nhưng dừng ngay trước b. Chỉ thời gian bắt đầu của đơn vị phương
tiện như khung hình video hoặc âm thanh mới có liên quan. Ví dụ: giả
sử rằng các khung hình video được tạo ra sau mỗi 40 ms. Phạm vi 10,0-
10,1 sẽ bao gồm khung hình video bắt đầu từ thời điểm 10,0 trở lên và
sẽ bao gồm khung hình video bắt đầu từ 10,08, mặc dù nó kéo dài vượt
quá khoảng thời gian. Mặt khác, phạm vi từ 10,0-10,08 sẽ loại trừ
khung ở mức 10,08.

Range            = "Range" ":" 1\#ranges-specifier
                          [ ";" "time" "=" utc-time ]
ranges-specifier = npt-range | utc-range | smpte-range

Example:
     Range: clock=19960213T143205Z-;time=19970123T143720Z

     Ký hiệu này tương tự như ký hiệu được sử dụng cho tiêu đề phạm vi
     byte HTTP/1.1 [2]. Nó cho phép khách hàng chọn một đoạn trích từ
     đối tượng phương tiện và phát từ một điểm nhất định đến điểm cuối
     cũng như từ vị trí hiện tại đến một điểm nhất định. Việc bắt đầu
     phát lại có thể được lên lịch vào bất kỳ lúc nào trong tương lai,
     mặc dù máy chủ có thể từ chối giữ tài nguyên máy chủ trong thời
     gian nhàn rỗi kéo dài.

### 12.30 Referer

Xem [H14.37]. URL đề cập đến mô tả bản trình bày, thường được truy
xuất qua HTTP.

### 12.31 Retry-After

Xem [H14.38].

### 12.32 Require

Tiêu đề Yêu cầu được khách hàng sử dụng để truy vấn máy chủ về các
tùy chọn mà nó có thể hỗ trợ hoặc không. Máy chủ PHẢI phản hồi tiêu
đề này bằng cách sử dụng tiêu đề Không được hỗ trợ để xác nhận một
cách tiêu cực những tùy chọn KHÔNG được hỗ trợ.

     Điều này nhằm đảm bảo rằng tương tác giữa máy khách và máy chủ sẽ
     diễn ra không chậm trễ khi cả hai bên đều hiểu tất cả các tùy chọn
     và chỉ chậm lại nếu không hiểu các tùy chọn (như trong trường hợp
     trên). Đối với một cặp máy khách-máy chủ phù hợp, quá trình tương
     tác diễn ra nhanh chóng, tiết kiệm một chuyến đi khứ hồi thường
     được cơ chế đàm phán yêu cầu. Ngoài ra, nó còn loại bỏ sự mơ hồ về
     trạng thái khi máy khách yêu cầu các tính năng mà máy chủ không
     hiểu.

Require =   "Require" ":"  1#option-tag

Example:
```http
C->S:   SETUP rtsp://server.com/foo/bar/baz.rm RTSP/1.0
             CSeq: 302
             Require: funky-feature
             Funky-Parameter: funkystuff

     S->C:   RTSP/1.0 551 Option not supported
             CSeq: 302
             Unsupported: funky-feature

     C->S:   SETUP rtsp://server.com/foo/bar/baz.rm RTSP/1.0
             CSeq: 303

     S->C:   RTSP/1.0 200 OK
             CSeq: 303
```

Trong ví dụ này, "funky-feature" là thẻ tính năng cho khách hàng biết
rằng trường Funky-Parameter hư cấu là bắt buộc. Mối quan hệ giữa
"funky-feature" và Funky-Parameter không được truyền đạt qua trao đổi
RTSP, vì mối quan hệ đó là thuộc tính bất biến của "funky-feature" và
do đó không được truyền đi trong mỗi lần trao đổi.

Proxy và các thiết bị trung gian khác NÊN bỏ qua các tính năng chưa
được hiểu rõ trong lĩnh vực này. Nếu một tiện ích mở rộng cụ thể yêu
cầu các thiết bị trung gian hỗ trợ nó thì thay vào đó, tiện ích mở
rộng đó phải được gắn thẻ trong trường Yêu cầu proxy (xem Phần
12.27).

### 12.33 RTP-Info

Trường này được sử dụng để đặt các tham số dành riêng cho RTP trong
phản hồi PLAY.

- **url:**
  Cho biết URL luồng tương ứng với các tham số RTP sau.

- **seq:**
  Cho biết số thứ tự của gói đầu tiên của luồng. Điều này cho
  phép khách hàng xử lý các gói một cách khéo léo khi tìm kiếm.
  Máy khách sử dụng giá trị này để phân biệt các gói có nguồn
  gốc trước khi tìm kiếm với các gói có nguồn gốc sau khi tìm
  kiếm.

- **rtptime:**
  Cho biết dấu thời gian RTP tương ứng với giá trị thời gian
  trong tiêu đề Phản hồi phạm vi. (Lưu ý: Để kiểm soát tổng hợp,
  một luồng cụ thể có thể không thực sự tạo ra gói cho giá trị
  Phạm vi thời gian được trả về hoặc ngụ ý. Do đó, không có gì
  đảm bảo rằng gói có số thứ tự được biểu thị bằng seq thực sự
  có dấu thời gian được biểu thị bằng rtptime.) Máy khách sử
  dụng giá trị này để tính toán ánh xạ thời gian RTP tới NPT.

     Ánh xạ từ dấu thời gian RTP sang dấu thời gian NTP (đồng hồ treo
     tường) có sẵn thông qua RTCP. Tuy nhiên, thông tin này không đủ để
     tạo ánh xạ từ nhãn thời gian RTP tới NPT. Hơn nữa, để đảm bảo rằng
     thông tin này có sẵn vào thời điểm cần thiết (ngay khi khởi động
     hoặc sau khi tìm kiếm) và được phân phối một cách đáng tin cậy, ánh
     xạ này được đặt trong kênh điều khiển RTSP.

     Để bù đắp cho sự trôi dạt trong các bản trình bày dài, không bị
     gián đoạn, các máy khách RTSP nên ánh xạ thêm NPT sang NTP, sử dụng
     các báo cáo ban đầu của người gửi RTCP để thực hiện ánh xạ và các
     báo cáo sau đó để kiểm tra sự lệch so với ánh xạ.

Syntax:

RTP-Info        = "RTP-Info" ":" 1#stream-url 1*parameter
stream-url      = "url" "=" url
parameter       = ";" "seq" "=" 1*DIGIT
                   | ";" "rtptime" "=" 1*DIGIT

Example:

     RTP-Info: url=rtsp://foo.com/bar.avi/streamid=0;seq=45102,
               url=rtsp://foo.com/bar.avi/streamid=1;seq=30211

### 12.34 Scale

Giá trị tỷ lệ là 1 biểu thị việc phát hoặc ghi bình thường ở tốc độ
xem xuôi bình thường. Nếu không phải là 1 thì giá trị tương ứng với
tỷ lệ xem bình thường. Ví dụ: tỷ lệ 2 biểu thị gấp đôi tốc độ xem
bình thường ("tua nhanh") và tỷ lệ 0,5 biểu thị một nửa tốc độ xem
bình thường. Nói cách khác, tỷ lệ 2 có thời gian chơi bình thường
tăng gấp đôi tốc độ đồng hồ treo tường. Cứ mỗi giây thời gian trôi
qua (đồng hồ treo tường), 2 giây nội dung sẽ được phân phối. Giá trị
âm cho biết hướng ngược lại.

Trừ khi có yêu cầu khác bởi tham số Tốc độ, tốc độ dữ liệu KHÔNG NÊN
thay đổi. Việc thực hiện thay đổi quy mô phụ thuộc vào máy chủ và
loại phương tiện. Ví dụ: đối với video, máy chủ có thể chỉ phân phối
các khung hình chính hoặc các khung hình chính đã chọn. Đối với âm
thanh, nó có thể chia tỷ lệ âm thanh theo thời gian trong khi vẫn giữ
nguyên cao độ hoặc ít mong muốn hơn là cung cấp các đoạn âm thanh.

Máy chủ nên cố gắng ước chừng tốc độ xem nhưng có thể hạn chế phạm vi
giá trị tỷ lệ mà nó hỗ trợ. Phản hồi PHẢI chứa giá trị tỷ lệ thực tế
được máy chủ chọn.

Nếu yêu cầu chứa tham số Phạm vi, giá trị thang đo mới sẽ có hiệu lực
tại thời điểm đó.

Scale = "Scale" ":" [ "-" ] 1*DIGIT [ "." *DIGIT ]

Ví dụ về chơi ngược với tốc độ gấp 3,5 lần bình thường:

     Scale: -3.5

### 12.35 Speed

Tham số trường tiêu đề yêu cầu này yêu cầu máy chủ phân phối dữ liệu
đến máy khách ở tốc độ cụ thể, tùy thuộc vào khả năng của máy chủ và
mong muốn phục vụ luồng phương tiện ở tốc độ nhất định. Việc triển
khai bởi máy chủ là TÙY CHỌN. Mặc định là tốc độ bit của luồng.

Giá trị tham số được biểu thị dưới dạng tỷ lệ thập phân, ví dụ: giá
trị 2,0 cho biết dữ liệu sẽ được phân phối nhanh gấp đôi so với bình
thường. Tốc độ bằng 0 là không hợp lệ. Nếu yêu cầu chứa tham số Phạm
vi, giá trị tốc độ mới sẽ có hiệu lực tại thời điểm đó.

Speed = "Speed" ":" 1*DIGIT [ "." *DIGIT ]

Example:
     Speed: 2.5

Việc sử dụng trường này sẽ thay đổi băng thông được sử dụng để phân
phối dữ liệu. Nó được thiết kế để sử dụng trong các trường hợp cụ thể
khi cần xem trước bản trình bày ở tốc độ cao hơn hoặc thấp hơn. Người
triển khai nên nhớ rằng băng thông cho phiên có thể được đàm phán
trước (bằng các phương tiện khác ngoài RTSP) và do đó việc đàm phán
lại có thể cần thiết. Khi dữ liệu được phân phối qua UDP, chúng tôi
khuyên bạn nên sử dụng các phương tiện như RTCP để theo dõi tốc độ
mất gói.

### 12.36 Server

Xem [H14.39]

### 12.37 Session

Trường tiêu đề phản hồi và yêu cầu này xác định phiên RTSP được máy
chủ phương tiện bắt đầu trong phản hồi THIẾT LẬP và được kết thúc
bằng TEARDOWN trên URL trình bày. Mã định danh phiên được chọn bởi
máy chủ phương tiện (xem Phần 3.4). Sau khi khách hàng nhận được mã
định danh Phiên, nó PHẢI trả lại nó cho bất kỳ yêu cầu nào liên quan
đến phiên đó. Máy chủ không phải thiết lập mã nhận dạng phiên nếu nó
có các phương tiện khác để xác định phiên, chẳng hạn như URL được tạo
động.

 Session  = "Session" ":" session-id [ ";" "timeout" "=" delta-seconds ]

Tham số thời gian chờ chỉ được phép trong tiêu đề phản hồi. Máy chủ
sử dụng nó để cho máy khách biết máy chủ sẵn sàng đợi bao lâu giữa
các lệnh RTSP trước khi đóng phiên do thiếu hoạt động (xem Phần A).
Thời gian chờ được đo bằng

giây, với mặc định là 60 giây (1 phút).

Lưu ý rằng mã định danh phiên xác định phiên RTSP trên các phiên
truyền tải hoặc kết nối. Thông báo điều khiển cho nhiều URL RTSP có
thể được gửi trong một phiên RTSP. Do đó, có thể khách hàng sử dụng
cùng một phiên để kiểm soát nhiều luồng tạo thành bản trình bày, miễn
là tất cả các luồng đều đến từ cùng một máy chủ. (Xem ví dụ ở Phần
14). Tuy nhiên, nhiều phiên "người dùng" cho cùng một URL từ cùng một
khách hàng PHẢI sử dụng các mã định danh phiên khác nhau.

     Cần có mã định danh phiên để phân biệt một số yêu cầu gửi cho cùng
     một URL đến từ cùng một khách hàng.

Phản hồi 454 (Không tìm thấy phiên) được trả về nếu mã định danh
phiên không hợp lệ.

### 12.38 Timestamp

Tiêu đề chung về dấu thời gian mô tả thời điểm máy khách gửi yêu cầu
đến máy chủ. Giá trị của dấu thời gian chỉ có ý nghĩa đối với khách
hàng và có thể sử dụng bất kỳ khoảng thời gian nào. Máy chủ PHẢI lặp
lại cùng một giá trị và CÓ THỂ, nếu có thông tin chính xác về điều
này, hãy thêm số dấu phẩy động cho biết số giây đã trôi qua kể từ khi
nhận được yêu cầu. Dấu thời gian được máy khách sử dụng để tính toán
thời gian khứ hồi tới máy chủ để nó có thể điều chỉnh giá trị thời
gian chờ cho các lần truyền lại.

Timestamp  = "Timestamp" ":" *(DIGIT) [ "." *(DIGIT) ] [ delay ]
delay      =  *(DIGIT) [ "." *(DIGIT) ]

### 12.39 Transport

Tiêu đề yêu cầu này cho biết giao thức truyền tải nào sẽ được sử dụng
và định cấu hình các tham số của nó như địa chỉ đích, độ nén, thời
gian tồn tại của multicast và cổng đích cho một luồng. Nó đặt những
giá trị chưa được xác định bởi mô tả bản trình bày.

Các phương tiện vận chuyển được phân tách bằng dấu phẩy, được liệt kê
theo thứ tự ưu tiên. Các tham số có thể được thêm vào mỗi lần vận
chuyển, được phân tách bằng dấu chấm phẩy.

Tiêu đề vận chuyển CÓ THỂ cũng được sử dụng để thay đổi các thông số
vận chuyển nhất định. Máy chủ CÓ THỂ từ chối thay đổi các tham số của
luồng hiện có.

Máy chủ CÓ THỂ trả về tiêu đề phản hồi Vận chuyển trong phản hồi để
cho biết các giá trị thực sự được chọn.

Trường tiêu đề yêu cầu vận chuyển có thể chứa danh sách các tùy chọn
vận chuyển được khách hàng chấp nhận. Trong trường hợp đó, máy chủ
PHẢI trả về một tùy chọn duy nhất đã thực sự được chọn.

Cú pháp của bộ xác định vận chuyển là

     vận chuyển/hồ sơ/vận chuyển thấp hơn.

Giá trị mặc định cho tham số "vận chuyển thấp hơn" dành riêng cho cấu
hình. Đối với RTP/AVP, mặc định là UDP.

Dưới đây là các thông số cấu hình liên quan đến vận chuyển:

Thông số chung:

đơn hướng | multicast: chỉ báo loại trừ lẫn nhau về việc phân phối
unicast hay multicast sẽ được thử. Giá trị mặc định là multicast. Các
khách hàng có khả năng xử lý cả truyền đơn hướng và đa hướng PHẢI chỉ
ra khả năng đó bằng cách bao gồm hai thông số kỹ thuật truyền tải đầy
đủ với các tham số riêng biệt cho mỗi thông số.

- **destination:**
  Địa chỉ mà luồng sẽ được gửi tới. Máy khách có thể chỉ định
  địa chỉ multicast với tham số đích. Để tránh trở thành thủ
  phạm vô tình của một cuộc tấn công từ chối dịch vụ được điều
  khiển từ xa, máy chủ NÊN xác thực ứng dụng khách và NÊN ghi
  lại các nỗ lực đó trước khi cho phép ứng dụng khách hướng
  luồng phương tiện đến địa chỉ không được máy chủ chọn. Điều
  này đặc biệt quan trọng nếu các lệnh RTSP được phát hành thông
  qua UDP, nhưng việc triển khai không thể dựa vào TCP như một
  phương tiện nhận dạng máy khách đáng tin cậy. Máy chủ KHÔNG
  NÊN cho phép máy khách hướng các luồng phương tiện đến một địa
  chỉ khác với địa chỉ mà các lệnh đến từ đó.

- **source:**
  Nếu địa chỉ nguồn của luồng khác với địa chỉ có thể được lấy
  từ địa chỉ điểm cuối RTSP (máy chủ đang phát lại hoặc máy
  khách đang ghi), nguồn CÓ THỂ được chỉ định.

     Thông tin này cũng có thể có sẵn thông qua SDP. Tuy nhiên, vì đây
     là một tính năng của truyền tải hơn là khởi tạo phương tiện nên
     nguồn có thẩm quyền cho thông tin này phải nằm trong phản hồi
     SETUP.

layers:
          Số lớp multicast được sử dụng cho luồng phương tiện này. Các
          lớp được gửi đến các địa chỉ liên tiếp bắt đầu từ địa chỉ
          đích.

- **mode:**
  Tham số chế độ cho biết các phương thức được hỗ trợ cho phiên
  này. Các giá trị hợp lệ là PLAY và RECORD. Nếu không được cung
  cấp, mặc định là CHƠI.

- **append:**
  Nếu tham số chế độ bao gồm RECORD, tham số chắp thêm cho biết
  rằng dữ liệu phương tiện sẽ nối thêm vào tài nguyên hiện có
  thay vì ghi đè lên nó. Nếu việc bổ sung được yêu cầu và máy
  chủ không hỗ trợ việc này, nó PHẢI từ chối yêu cầu thay vì ghi
  đè lên tài nguyên được xác định bởi URI. Tham số chắp thêm bị
  bỏ qua nếu tham số chế độ không chứa RECORD.

- **interleaved:**
  Tham số xen kẽ ngụ ý việc trộn luồng phương tiện với luồng
  điều khiển trong bất kỳ giao thức nào đang được luồng điều
  khiển sử dụng, sử dụng cơ chế được xác định trong Phần 10.12.
  Đối số cung cấp số kênh sẽ được sử dụng trong câu lệnh $. Tham
  số này có thể được chỉ định dưới dạng một phạm vi, ví dụ:
  interleaved=4-5 trong trường hợp lựa chọn truyền tải cho luồng
  phương tiện yêu cầu nó.

     Điều này cho phép RTP/RTCP được xử lý tương tự như cách nó được
     thực hiện với UDP, tức là một kênh cho RTP và kênh kia cho RTCP.

Đa phương tiện cụ thể:

- **ttl:**
  thời gian tồn tại của multicast

RTP cụ thể:

- **port:**
  Tham số này cung cấp cặp cổng RTP/RTCP cho phiên phát đa
  hướng. Nó được chỉ định dưới dạng một phạm vi, ví dụ:
  port=3456-3457.

- **client_port:**
  Tham số này cung cấp cặp cổng unicast RTP/RTCP mà máy khách đã
  chọn để nhận dữ liệu đa phương tiện và thông tin điều khiển.
  Nó được chỉ định dưới dạng một phạm vi, ví dụ:
  client_port=3456-3457.

server_port:
          Tham số này cung cấp cặp cổng unicast RTP/RTCP mà máy chủ đã
          chọn để nhận dữ liệu đa phương tiện và thông tin điều khiển.
          Nó được chỉ định dưới dạng một phạm vi, ví dụ:
          server_port=3456-3457.

- **ssrc:**
  Tham số ssrc biểu thị RTP SSRC [24, Sec. 3] giá trị phải là
  (yêu cầu) hoặc sẽ là (phản hồi) được sử dụng bởi máy chủ
  phương tiện. Tham số này chỉ có giá trị đối với truyền đơn
  hướng. Nó xác định nguồn đồng bộ hóa được liên kết với luồng
  phương tiện.

Transport           =    "Transport" ":"
                            1\#transport-spec
transport-spec      =    transport-protocol/profile[/lower-transport]
                            *parameter
transport-protocol  =    "RTP"
profile             =    "AVP"
lower-transport     =    "TCP" | "UDP"
parameter           =    ( "unicast" | "multicast" )
                       |    ";" "destination" [ "=" address ]
                       |    ";" "interleaved" "=" channel [ "-" channel ]
                       |    ";" "append"
                       |    ";" "ttl" "=" ttl
                       |    ";" "layers" "=" 1*DIGIT
                       |    ";" "port" "=" port [ "-" port ]
                       |    ";" "client_port" "=" port [ "-" port ]
                       |    ";" "server_port" "=" port [ "-" port ]
                       |    ";" "ssrc" "=" ssrc
                       |    ";" "mode" = <"> 1\#mode <">
ttl                 =    1*3(DIGIT)
port                =    1*5(DIGIT)
ssrc                =    8*8(HEX)
channel             =    1*3(DIGIT)
address             =    host
mode                =    <"> *Method <"> | Method

Example:
     Transport: RTP/AVP;multicast;ttl=127;mode="PLAY",
                RTP/AVP;unicast;client_port=3456-3457;mode="PLAY"

     Tiêu đề Transport bị hạn chế để mô tả một luồng RTP. (RTSP cũng có
     thể kiểm soát nhiều luồng dưới dạng một thực thể duy nhất.) Biến nó
     thành một phần của RTSP thay vì dựa vào vô số định dạng mô tả phiên
     giúp đơn giản hóa đáng kể việc thiết kế tường lửa.

### 12.40 Unsupported

Tiêu đề phản hồi không được hỗ trợ liệt kê các tính năng không được
máy chủ hỗ trợ. Trong trường hợp tính năng được chỉ định thông qua
trường Yêu cầu proxy (Phần 12.32), nếu có proxy trên đường dẫn giữa
máy khách và máy chủ, proxy PHẢI chèn thư trả lời có thông báo lỗi
"Tùy chọn 551 không được hỗ trợ".

Xem Phần 12.32 để biết ví dụ sử dụng.

### 12.41 User-Agent

Xem [H14.42]

### 12.42 Vary

Xem [H14.43]

### 12.43 Via

Xem [H14.44].

### 12.44 WWW-Authenticate

Xem [H14.46].

## 13 Lưu vào bộ nhớ đệm (Caching)

Trong HTTP, các cặp yêu cầu phản hồi được lưu trữ trong bộ nhớ đệm.
RTSP khác biệt đáng kể về mặt đó. Các câu trả lời không được lưu vào
bộ nhớ đệm, ngoại trừ phần mô tả bản trình bày được trả về bởi MÔ TẢ
hoặc được bao gồm trong THÔNG BÁO. (Vì các phản hồi cho bất kỳ nội
dung nào ngoại trừ DESCRIBE và GET_PARAMETER không trả về bất kỳ dữ
liệu nào nên bộ nhớ đệm không thực sự là vấn đề đối với những yêu cầu
này.) Tuy nhiên, điều mong muốn là dữ liệu phương tiện liên tục,
thường được phân phối ngoài băng tần đối với RTSP, sẽ được lưu vào bộ
đệm, cũng như mô tả phiên.

Khi nhận được yêu cầu THIẾT LẬP hoặc PHÁT, proxy sẽ xác định xem liệu
nó có bản sao cập nhật của nội dung phương tiện liên tục và mô tả của
nó hay không. Nó có thể xác định xem bản sao có được cập nhật hay
không bằng cách đưa ra yêu cầu SETUP hoặc DESCRIBE tương ứng và so
sánh tiêu đề Sửa đổi lần cuối với tiêu đề của bản sao được lưu trong
bộ nhớ đệm. Nếu bản sao không được cập nhật, nó sẽ sửa đổi các tham
số truyền tải SETUP cho phù hợp và chuyển tiếp yêu cầu đến máy chủ
gốc. Các lệnh điều khiển tiếp theo như CHƠI hoặc TẠM DỪNG sẽ chuyển
proxy chưa được sửa đổi. Proxy cung cấp dữ liệu đa phương tiện liên
tục cho máy khách, đồng thời có thể tạo một bản sao cục bộ để sử dụng
lại sau này. Hành vi chính xác được phép đối với bộ đệm được đưa ra
bởi các chỉ thị phản hồi bộ đệm

được mô tả trong Phần 12.8. Bộ đệm PHẢI trả lời bất kỳ yêu cầu MÔ TẢ
nào nếu nó hiện đang phân phát luồng cho người yêu cầu, vì có thể các
chi tiết cấp thấp của mô tả luồng có thể đã thay đổi trên máy chủ
gốc.

Lưu ý rằng bộ đệm RTSP, không giống như bộ đệm HTTP, thuộc loại "cắt
ngang". Thay vì lấy toàn bộ tài nguyên từ máy chủ gốc, bộ đệm chỉ sao
chép dữ liệu phát trực tuyến khi nó đi qua máy khách. Vì vậy, nó
không gây ra độ trễ bổ sung.

Đối với máy khách, bộ đệm proxy RTSP xuất hiện giống như một máy chủ
phương tiện thông thường, đối với máy chủ gốc phương tiện giống như
một máy khách. Giống như bộ đệm HTTP phải lưu trữ loại nội dung, ngôn
ngữ nội dung, v.v. cho các đối tượng mà nó lưu vào bộ đệm, bộ đệm
phương tiện phải lưu trữ mô tả bản trình bày. Thông thường, bộ đệm sẽ
loại bỏ tất cả các tham chiếu truyền tải (nghĩa là thông tin
multicast) khỏi mô tả bản trình bày, vì chúng độc lập với việc phân
phối dữ liệu từ bộ đệm đến máy khách. Thông tin về bảng mã vẫn giữ
nguyên. Nếu bộ nhớ đệm có thể dịch dữ liệu phương tiện được lưu trong
bộ nhớ đệm, nó sẽ tạo một mô tả bản trình bày mới với tất cả các khả
năng mã hóa mà nó có thể cung cấp.

## 14 Các ví dụ (Examples)

Các ví dụ sau đề cập đến các định dạng mô tả luồng không phải là tiêu
chuẩn, chẳng hạn như RTSL. Các ví dụ sau đây không được sử dụng làm
tài liệu tham khảo cho các định dạng đó.

### 14.1 Truyền thông theo yêu cầu (Unicast) - Media on Demand (Unicast)

Khách hàng C yêu cầu phim từ máy chủ phương tiện A (
audio.example.com) và V (video.example.com). Mô tả phương tiện được
lưu trữ trên máy chủ web W. Mô tả phương tiện chứa các mô tả về bản
trình bày và tất cả các luồng của nó, bao gồm các codec có sẵn, loại
tải trọng RTP động, ngăn xếp giao thức và thông tin nội dung như hạn
chế về ngôn ngữ hoặc bản quyền. Nó cũng có thể đưa ra dấu hiệu về
dòng thời gian của bộ phim.

Trong ví dụ này, khách hàng chỉ quan tâm đến phần cuối của bộ phim.

```http
C->W: GET /twister.sdp HTTP/1.1
           Host: www.example.com
           Accept: application/sdp

     W->C: HTTP/1.0 200 OK
           Content-Type: application/sdp

v=0
           o=- 2890844526 2890842807 IN IP4 192.16.24.202
           s=RTSP Session
           m=audio 0 RTP/AVP 0
           a=control:rtsp://audio.example.com/twister/audio.en
           m=video 0 RTP/AVP 31
           a=control:rtsp://video.example.com/twister/video

     C->A: SETUP rtsp://audio.example.com/twister/audio.en RTSP/1.0
           CSeq: 1
           Transport: RTP/AVP/UDP;unicast;client_port=3056-3057

     A->C: RTSP/1.0 200 OK
           CSeq: 1
           Session: 12345678
           Transport: RTP/AVP/UDP;unicast;client_port=3056-3057;
                      server_port=5000-5001

     C->V: SETUP rtsp://video.example.com/twister/video RTSP/1.0
           CSeq: 1
           Transport: RTP/AVP/UDP;unicast;client_port=3058-3059

     V->C: RTSP/1.0 200 OK
           CSeq: 1
           Session: 23456789
           Transport: RTP/AVP/UDP;unicast;client_port=3058-3059;
                      server_port=5002-5003

     C->V: PLAY rtsp://video.example.com/twister/video RTSP/1.0
           CSeq: 2
           Session: 23456789
           Range: smpte=0:10:00-

     V->C: RTSP/1.0 200 OK
           CSeq: 2
           Session: 23456789
           Range: smpte=0:10:00-0:20:00
           RTP-Info: url=rtsp://video.example.com/twister/video;
             seq=12312232;rtptime=78712811

     C->A: PLAY rtsp://audio.example.com/twister/audio.en RTSP/1.0
           CSeq: 2
           Session: 12345678
           Range: smpte=0:10:00-

     A->C: RTSP/1.0 200 OK
           CSeq: 2
           Session: 12345678

Range: smpte=0:10:00-0:20:00
           RTP-Info: url=rtsp://audio.example.com/twister/audio.en;
             seq=876655;rtptime=1032181

     C->A: TEARDOWN rtsp://audio.example.com/twister/audio.en RTSP/1.0
           CSeq: 3
           Session: 12345678

     A->C: RTSP/1.0 200 OK
           CSeq: 3

     C->V: TEARDOWN rtsp://video.example.com/twister/video RTSP/1.0
           CSeq: 3
           Session: 23456789

     V->C: RTSP/1.0 200 OK
           CSeq: 3
```

Mặc dù bản nhạc âm thanh và video nằm trên hai máy chủ khác nhau và
có thể bắt đầu ở những thời điểm hơi khác nhau và có thể lệch nhau,
khách hàng có thể đồng bộ hóa cả hai bằng các phương pháp RTP tiêu
chuẩn, đặc biệt là thang thời gian có trong báo cáo của người gửi
RTCP.

### 14.2 Truyền phát tệp chứa (Container file) - Streaming of a Container File

Đối với mục đích của ví dụ này, tệp vùng chứa là một thực thể lưu trữ
trong đó có nhiều loại phương tiện liên tục liên quan đến cùng một
bản trình bày của người dùng cuối. Trên thực tế, tệp vùng chứa biểu
thị một bản trình bày RTSP, với mỗi thành phần của nó là các luồng
RTSP. Tệp vùng chứa là phương tiện được sử dụng rộng rãi để lưu trữ
các bản trình bày như vậy. Mặc dù các thành phần được vận chuyển dưới
dạng các luồng độc lập, nhưng điều mong muốn là duy trì bối cảnh
chung cho các luồng đó ở cuối máy chủ.

     Điều này cho phép máy chủ giữ một bộ điều khiển lưu trữ duy nhất
     được mở một cách dễ dàng. Nó cũng cho phép xử lý tất cả các luồng
     như nhau trong trường hợp máy chủ ưu tiên các luồng.

Cũng có thể tác giả bản trình bày muốn ngăn chặn việc khách hàng truy
xuất có chọn lọc các luồng để duy trì hiệu quả nghệ thuật của bản
trình bày đa phương tiện kết hợp. Tương tự, trong cách trình bày bị
ràng buộc chặt chẽ như vậy, điều mong muốn là có thể kiểm soát tất cả
các luồng thông qua một thông báo điều khiển duy nhất bằng cách sử
dụng một URL tổng hợp.

Sau đây là ví dụ về việc sử dụng một phiên RTSP để điều khiển nhiều
luồng. Nó cũng minh họa việc sử dụng các URL tổng hợp.

Máy khách C yêu cầu bản trình bày từ máy chủ phương tiện M . Phim
được lưu trữ trong một tập tin chứa. Máy khách đã nhận được URL RTSP
tới tệp vùng chứa.

```http
C->M: DESCRIBE rtsp://foo/twister RTSP/1.0
           CSeq: 1

     M->C: RTSP/1.0 200 OK
           CSeq: 1
           Content-Type: application/sdp
           Content-Length: 164

           v=0
           o=- 2890844256 2890842807 IN IP4 172.16.2.93
           s=RTSP Session
           i=An Example of RTSP Session Usage
           a=control:rtsp://foo/twister
           t=0 0
           m=audio 0 RTP/AVP 0
           a=control:rtsp://foo/twister/audio
           m=video 0 RTP/AVP 26
           a=control:rtsp://foo/twister/video

     C->M: SETUP rtsp://foo/twister/audio RTSP/1.0
           CSeq: 2
           Transport: RTP/AVP;unicast;client_port=8000-8001

     M->C: RTSP/1.0 200 OK
           CSeq: 2
           Transport: RTP/AVP;unicast;client_port=8000-8001;
                      server_port=9000-9001
           Session: 12345678

     C->M: SETUP rtsp://foo/twister/video RTSP/1.0
           CSeq: 3
           Transport: RTP/AVP;unicast;client_port=8002-8003
           Session: 12345678

     M->C: RTSP/1.0 200 OK
           CSeq: 3
           Transport: RTP/AVP;unicast;client_port=8002-8003;
                      server_port=9004-9005
           Session: 12345678

     C->M: PLAY rtsp://foo/twister RTSP/1.0
           CSeq: 4
           Range: npt=0-
           Session: 12345678

M->C: RTSP/1.0 200 OK
           CSeq: 4
           Session: 12345678
           RTP-Info: url=rtsp://foo/twister/video;
             seq=9810092;rtptime=3450012

     C->M: PAUSE rtsp://foo/twister/video RTSP/1.0
           CSeq: 5
           Session: 12345678

     M->C: RTSP/1.0 460 Only aggregate operation allowed
           CSeq: 5

     C->M: PAUSE rtsp://foo/twister RTSP/1.0
           CSeq: 6
           Session: 12345678

     M->C: RTSP/1.0 200 OK
           CSeq: 6
           Session: 12345678

     C->M: SETUP rtsp://foo/twister RTSP/1.0
           CSeq: 7
           Transport: RTP/AVP;unicast;client_port=10000

     M->C: RTSP/1.0 459 Aggregate operation not allowed
           CSeq: 7
```

Trong trường hợp lỗi đầu tiên, máy khách cố gắng tạm dừng một luồng
(trong trường hợp này là video) của bản trình bày. Điều này không
được máy chủ cho phép trình bày. Trong trường hợp thứ hai, URL tổng
hợp có thể không được sử dụng cho THIẾT LẬP và cần có một thông báo
điều khiển cho mỗi luồng để thiết lập các tham số truyền tải.

     Điều này giữ cho cú pháp của tiêu đề Transport đơn giản và cho phép
     tường lửa phân tích thông tin truyền tải dễ dàng.

### 14.3 Tệp chứa luồng đơn - Single Stream Container Files

Một số máy chủ RTSP có thể coi tất cả các tệp như thể chúng là "tệp
chứa", tuy nhiên các máy chủ khác có thể không hỗ trợ khái niệm như
vậy. Vì điều này, khách hàng NÊN sử dụng các quy tắc được đặt ra
trong mô tả phiên cho các URL yêu cầu, thay vì cho rằng một URL nhất
quán có thể luôn được sử dụng xuyên suốt. Đây là một ví dụ về cách
một máy chủ đa luồng có thể mong đợi một tệp một luồng được cung cấp:

          Accept: application/x-rtsp-mh, application/sdp

CSeq: 1

S->C RTSP/1.0 200 OK CSeq: 1 Cơ sở nội dung: rtsp://foo.com/test.wav/
Kiểu nội dung: application/sdp Độ dài nội dung: 48

          v=0
          o=- 872653257 872653257 IN IP4 172.16.2.187
          s=mu-law wave file
          i=audio test
          t=0 0
          m=audio 0 RTP/AVP 0
          a=control:streamid=0

    C->S  SETUP rtsp://foo.com/test.wav/streamid=0 RTSP/1.0
          Transport: RTP/AVP/UDP;unicast;
                     client_port=6970-6971;mode=play
          CSeq: 2

     S->C  RTSP/1.0 200 OK
           Transport: RTP/AVP/UDP;unicast;client_port=6970-6971;
                      server_port=6970-6971;mode=play
           CSeq: 2
           Session: 2034820394

    C->S  PLAY rtsp://foo.com/test.wav RTSP/1.0
          CSeq: 3
          Session: 2034820394

     S->C  RTSP/1.0 200 OK
           CSeq: 3
           Session: 2034820394
           RTP-Info: url=rtsp://foo.com/test.wav/streamid=0;
             seq=981888;rtptime=3781123

Lưu ý URL khác trong lệnh SETUP, sau đó chuyển về URL tổng hợp trong
lệnh PLAY. Điều này hoàn toàn hợp lý khi có nhiều luồng có quyền kiểm
soát tổng hợp, nhưng kém trực quan hơn trong trường hợp đặc biệt khi
số lượng luồng là một.

Trong trường hợp đặc biệt này, máy chủ nên bỏ qua các triển khai gửi:

    C->S  PLAY rtsp://foo.com/test.wav/streamid=0 RTSP/1.0
          CSeq: 3

Trong trường hợp xấu nhất, máy chủ sẽ gửi lại:

    S->C  RTSP/1.0 460 Only aggregate operation allowed
          CSeq: 3

Người ta cũng hy vọng rằng việc triển khai máy chủ cũng sẽ bỏ qua
những điều sau:

    C->S  SETUP rtsp://foo.com/test.wav RTSP/1.0
          Transport: rtp/avp/udp;client_port=6970-6971;mode=play
          CSeq: 2

Vì chỉ có một luồng duy nhất trong tệp này nên không rõ điều này có
nghĩa là gì.

### 14.4 Trình chiếu media trực tiếp dùng Multicast - Live Media Presentation Using Multicast

Máy chủ đa phương tiện M chọn địa chỉ và cổng multicast. Ở đây, chúng
tôi giả sử rằng máy chủ web chỉ chứa một con trỏ tới mô tả đầy đủ,
trong khi máy chủ phương tiện M duy trì mô tả đầy đủ.

```http
C->W: GET /concert.sdp HTTP/1.1
           Host: www.example.com

     W->C: HTTP/1.1 200 OK
           Content-Type: application/x-rtsl

     <session> <track src="rtsp://live.example.com/concert/audio">
     </session>

     C->M: DESCRIBE rtsp://live.example.com/concert/audio RTSP/1.0
           CSeq: 1

     M->C: RTSP/1.0 200 OK
           CSeq: 1
           Content-Type: application/sdp
           Content-Length: 44

           v=0
           o=- 2890844526 2890842807 IN IP4 192.16.24.202
           s=RTSP Session
           m=audio 3456 RTP/AVP 0
           a=control:rtsp://live.example.com/concert/audio
           c=IN IP4 224.2.0.1/16

     C->M: SETUP rtsp://live.example.com/concert/audio RTSP/1.0
           CSeq: 2

Transport: RTP/AVP;multicast

     M->C: RTSP/1.0 200 OK
           CSeq: 2
           Transport: RTP/AVP;multicast;destination=224.2.0.1;
                      port=3456-3457;ttl=16
           Session: 0456804596

     C->M: PLAY rtsp://live.example.com/concert/audio RTSP/1.0
           CSeq: 3
           Session: 0456804596

     M->C: RTSP/1.0 200 OK
           CSeq: 3
           Session: 0456804596
```

### 14.5 Phát media vào một phiên hiện có - Playing Media into an Existing Session

Một người tham gia hội nghị C muốn máy chủ phương tiện M phát lại
đoạn băng demo trong một hội nghị hiện có. C cho máy chủ phương tiện
biết rằng địa chỉ mạng và khóa mã hóa đã được hội nghị cung cấp, do
đó máy chủ không nên chọn chúng. Ví dụ này bỏ qua các phản hồi ACK
đơn giản.

```http
C->M: DESCRIBE rtsp://server.example.com/demo/548/sound RTSP/1.0
           CSeq: 1
           Accept: application/sdp

     M->C: RTSP/1.0 200 OK
           Content-type: application/sdp
           Content-Length: 44

           v=0
           o=- 2890844526 2890842807 IN IP4 192.16.24.202
           s=RTSP Session
           i=See above
           t=0 0
           m=audio 0 RTP/AVP 0

     C->M: SETUP rtsp://server.example.com/demo/548/sound RTSP/1.0
           CSeq: 2
           Transport: RTP/AVP;multicast;destination=225.219.201.15;
                      port=7000-7001;ttl=127
           Conference: 199702170042.SAA08642@obiwan.arl.wustl.edu%20Starr

     M->C: RTSP/1.0 200 OK
           CSeq: 2
           Transport: RTP/AVP;multicast;destination=225.219.201.15;
```

port=7000-7001;ttl=127
           Session: 91389234234
           Conference: 199702170042.SAA08642@obiwan.arl.wustl.edu%20Starr

```http
C->M: PLAY rtsp://server.example.com/demo/548/sound RTSP/1.0
           CSeq: 3
           Session: 91389234234

     M->C: RTSP/1.0 200 OK
           CSeq: 3
```

### 14.6 Ghi dữ liệu (Recording)

Máy khách tham gia hội nghị C yêu cầu máy chủ đa phương tiện M ghi
lại các phần âm thanh và video của cuộc họp. Máy khách sử dụng phương
thức THÔNG BÁO để cung cấp thông tin meta về phiên được ghi cho máy
chủ.

```http
C->M: ANNOUNCE rtsp://server.example.com/meeting RTSP/1.0
           CSeq: 90
           Content-Type: application/sdp
           Content-Length: 121

           v=0
           o=camera1 3080117314 3080118787 IN IP4 195.27.192.36
           s=IETF Meeting, Munich - 1
           i=The thirty-ninth IETF meeting will be held in Munich, Germany
           u=http://www.ietf.org/meetings/Munich.html
           e=IETF Channel 1 <ietf39-mbone@uni-koeln.de>
           p=IETF Channel 1 +49-172-2312 451
           c=IN IP4 224.0.1.11/127
           t=3080271600 3080703600
           a=tool:sdr v2.4a6
           a=type:test
           m=audio 21010 RTP/AVP 5
           c=IN IP4 224.0.1.11/127
           a=ptime:40
           m=video 61010 RTP/AVP 31
           c=IN IP4 224.0.1.12/127

     M->C: RTSP/1.0 200 OK
           CSeq: 90

     C->M: SETUP rtsp://server.example.com/meeting/audiotrack RTSP/1.0
           CSeq: 91
           Transport: RTP/AVP;multicast;destination=224.0.1.11;
                      port=21010-21011;mode=record;ttl=127

M->C: RTSP/1.0 200 OK
           CSeq: 91
           Session: 50887676
           Transport: RTP/AVP;multicast;destination=224.0.1.11;
                      port=21010-21011;mode=record;ttl=127

     C->M: SETUP rtsp://server.example.com/meeting/videotrack RTSP/1.0
           CSeq: 92
           Session: 50887676
           Transport: RTP/AVP;multicast;destination=224.0.1.12;
                      port=61010-61011;mode=record;ttl=127

     M->C: RTSP/1.0 200 OK
           CSeq: 92
           Transport: RTP/AVP;multicast;destination=224.0.1.12;
                      port=61010-61011;mode=record;ttl=127

     C->M: RECORD rtsp://server.example.com/meeting RTSP/1.0
           CSeq: 93
           Session: 50887676
           Range: clock=19961110T1925-19961110T2015

     M->C: RTSP/1.0 200 OK
           CSeq: 93
```

## 15 Cú pháp (Syntax)

Cú pháp RTSP được mô tả bằng dạng Backus-Naur mở rộng (BNF)
như được sử dụng trong RFC 2068 [2].

### 15.1 Cú pháp cơ sở (Base Syntax)

```abnf
OCTET              =      <any 8-bit sequence of data>
CHAR               =      <any US-ASCII character (octets 0 - 127)>
UPALPHA            =      <any US-ASCII uppercase letter "A".."Z">
LOALPHA            =      <any US-ASCII lowercase letter "a".."z">
ALPHA              =      UPALPHA | LOALPHA

DIGIT              =      <any US-ASCII digit "0".."9">
CTL                =      <any US-ASCII control character
(octets 0 - 31) and DEL (127)>
CR                 =      <US-ASCII CR, carriage return (13)>
LF                 =      <US-ASCII LF, linefeed (10)>

SP                 =      <US-ASCII SP, space (32)>
HT                 =      <US-ASCII HT, horizontal-tab (9)>
<">                =      <US-ASCII double-quote mark (34)>
CRLF               =      CR LF

LWS                =      [CRLF] 1*( SP | HT )
TEXT               =      <any OCTET except CTLs>
tspecials          =      "(" | ")" | "<" | ">" | "@"
|       "," | ";" | ":" | "\" | <">
|       "/" | "[" | "]" | "?" | "="
|       "{" | "}" | SP | HT

token              =      1*<any CHAR except CTLs or tspecials>
quoted-string      =      ( <"> *(qdtext) <"> )
qdtext             =      <any TEXT except <">>
quoted-pair        =      "\" CHAR

message-header     =      field-name ":" [ field-value ] CRLF
field-name         =      token
field-value        =      *( field-content | LWS )
field-content      =      <the OCTETs making up the field-value and
consisting of either *TEXT or
combinations of token, tspecials, and
quoted-string>

safe               =  "\$" | "-" | "_" | "." | "+"
extra              =  "!" | "*" | "$'$" | "(" | ")" | ","

hex                =  DIGIT | "A" | "B" | "C" | "D" | "E" | "F" |
"a" | "b" | "c" | "d" | "e" | "f"
escape             =  "\%" hex hex
reserved           =  ";" | "/" | "?" | ":" | "@" | "&" | "="

unreserved         =  alpha | digit | safe | extra
xchar              =  unreserved | reserved | escape

```

## 16 Các cân nhắc về bảo mật (Security Considerations)

Do sự tương đồng về cú pháp và cách sử dụng giữa các máy chủ RTSP
và máy chủ HTTP, các cân nhắc về bảo mật được nêu trong [H15] được
áp dụng. Cụ thể, xin lưu ý những điều sau:

- **Cơ chế xác thực:**
  RTSP và HTTP dùng chung các cơ chế xác thực, và do đó nên
  tuân theo cùng các quy định liên quan đến xác thực. Xem
  [H15.1] về các vấn đề xác thực máy khách, và [H15.2] về các
  vấn đề liên quan đến việc hỗ trợ nhiều cơ chế xác thực.

- **Lạm dụng thông tin nhật ký máy chủ:**
  Các máy chủ RTSP và HTTP có thể sẽ có các cơ chế ghi nhật ký
  tương tự nhau, và do đó nên được cẩn trọng tương đương trong
  việc bảo vệ nội dung của các nhật ký đó, nhờ đó bảo vệ quyền
  riêng tư của

người dùng máy chủ. Xem [H15.3] để biết các khuyến nghị dành
          cho máy chủ HTTP liên quan đến nhật ký máy chủ.

- **Truyền thông tin nhạy cảm:**
  Không có lý do gì để tin rằng thông tin được truyền qua RTSP
  lại kém nhạy cảm hơn thông tin thường được truyền qua HTTP.
  Do đó, tất cả các biện pháp phòng ngừa liên quan đến việc
  bảo vệ quyền riêng tư của dữ liệu và người dùng đều áp dụng
  cho các bên triển khai máy khách, máy chủ và proxy RTSP. Xem
  [H15.4] để biết thêm chi tiết.

- **Tấn công dựa trên tên tệp và tên đường dẫn:**
  Mặc dù các URL RTSP là các bộ xử lý không trong suốt không
  nhất thiết có ngữ nghĩa hệ thống tệp, người ta dự đoán rằng
  nhiều bản triển khai sẽ chuyển trực tiếp các phần của URL yêu
  cầu thành các lệnh gọi hệ thống tệp. Trong những trường hợp
  như vậy, hệ thống tệp NÊN tuân theo các biện pháp phòng ngừa
  được nêu trong [H15.5], chẳng hạn như kiểm tra ".." trong các
  thành phần đường dẫn.

- **Thông tin cá nhân:**
  Các máy khách RTSP thường nắm được cùng loại thông tin mà máy
  khách HTTP có (tên người dùng, vị trí, v.v.) và do đó nên
  được bảo vệ tương đương. Xem [H15.6] để biết thêm các khuyến
  nghị.

- **Vấn đề riêng tư liên quan đến tiêu đề Accept:**
  Vì nhiều tiêu đề "Accept" tương tự tồn tại trong cả RTSP và
  HTTP, các lưu ý tương tự được nêu trong [H15.7] liên quan đến
  việc sử dụng chúng nên được tuân thủ.

- **Giả mạo DNS:**
  Có thể cho rằng, do thời gian kết nối thường dài hơn đối với
  các phiên RTSP so với các phiên HTTP, các tối ưu hóa DNS của
  máy khách RTSP sẽ ít phổ biến hơn. Tuy nhiên, các khuyến nghị
  được đưa ra trong [H15.8] vẫn phù hợp với bất kỳ bản triển
  khai nào cố gắng dựa vào một ánh xạ DNS-sang-IP duy trì vượt
  quá một lần sử dụng duy nhất của ánh xạ đó.

- **Tiêu đề Location và giả mạo:**
  Nếu một máy chủ duy nhất hỗ trợ nhiều tổ chức không tin cậy
  lẫn nhau, thì máy chủ đó phải kiểm tra các giá trị của các
  tiêu đề Location và Content-Location trong các phản hồi được
  tạo ra dưới sự kiểm soát của các tổ chức nói trên để đảm bảo
  rằng họ không cố gắng làm mất hiệu lực các tài nguyên mà họ
  không có thẩm quyền. ([H15.9])

Ngoài các khuyến nghị trong đặc tả HTTP hiện tại (RFC 2068 [2], tại
thời điểm viết tài liệu này), các đặc tả HTTP trong tương lai có thể
cung cấp thêm hướng dẫn về các vấn đề bảo mật.

Dưới đây là các cân nhắc bổ sung cho các bản triển khai RTSP.

- **Tấn công từ chối dịch vụ tập trung:**
  Giao thức tạo cơ hội cho một cuộc tấn công từ chối dịch vụ
  được điều khiển từ xa. Kẻ tấn công có thể khởi tạo các luồng
  lưu lượng truy cập đến một hoặc nhiều địa chỉ IP bằng cách chỉ
  định chúng làm đích trong các yêu cầu SETUP. Mặc dù địa chỉ
  IP của kẻ tấn công có thể được biết trong trường hợp này, điều
  này không phải lúc nào cũng hữu ích trong việc ngăn chặn thêm
  các cuộc tấn công hoặc xác định danh tính kẻ tấn công. Do đó,
  máy chủ RTSP NÊN chỉ cho phép các đích do máy khách chỉ định
  cho các luồng lưu lượng do RTSP khởi tạo nếu máy chủ đã xác
  minh danh tính máy khách, qua cơ sở dữ liệu người dùng đã biết
  dùng các cơ chế xác thực RTSP (ưu tiên xác thực digest hoặc
  mạnh hơn), hoặc các biện pháp bảo mật khác.

- **Chiếm quyền điều khiển phiên:**
  Vì không có mối quan hệ giữa kết nối tầng truyền vận và phiên
  RTSP, nên một máy khách độc hại có thể gửi các yêu cầu với
  định danh phiên ngẫu nhiên làm ảnh hưởng đến các máy khách vô
  tội. Máy chủ NÊN sử dụng một mã định danh phiên lớn, ngẫu
  nhiên và không tuần tự để giảm thiểu khả năng xảy ra loại tấn
  công này.

- **Xác thực:**
  Các máy chủ NÊN triển khai cả xác thực basic và digest [8].
  Trong các môi trường đòi hỏi tính bảo mật chặt chẽ hơn cho
  các thông điệp điều khiển, luồng điều khiển RTSP có thể được
  mã hóa.

- **Các vấn đề về luồng:**
  RTSP chỉ cung cấp việc điều khiển luồng. Các vấn đề truyền
  phát luồng không được đề cập trong mục này, cũng như trong
  phần còn lại của tài liệu này. Các bản triển khai RTSP nhiều
  khả năng sẽ dựa vào các giao thức khác như RTP, IP multicast,
  RSVP và IGMP, và nên giải quyết các cân nhắc về bảo mật được
  nêu trong các tài liệu đặc tả đó và các đặc tả áp dụng khác.

- **Hành vi đáng ngờ dai dẳng:**
  Máy chủ RTSP NÊN trả về mã lỗi 403 (Forbidden) khi nhận được
  một trường hợp hành vi duy nhất bị coi là rủi ro bảo mật. Máy
  chủ RTSP cũng NÊN lưu ý đến các nỗ lực thăm dò máy chủ để tìm
  điểm yếu và điểm xâm nhập và CÓ THỂ ngắt kết nối tùy ý và bỏ
  qua các yêu cầu tiếp theo từ các máy khách bị coi là vi phạm
  chính sách bảo mật cục bộ.

## Phụ lục A: Máy trạng thái giao thức RTSP

Các máy trạng thái máy khách và máy chủ RTSP mô tả hành vi của
giao thức từ khi khởi tạo phiên RTSP cho đến khi kết thúc phiên
RTSP.

Trạng thái được định nghĩa trên cơ sở từng đối tượng. Một đối tượng
được định danh duy nhất bởi URL của luồng và mã định danh phiên
RTSP. Mọi yêu cầu/phản hồi sử dụng URL tổng hợp chỉ định các bản
trình bày RTSP bao gồm nhiều luồng sẽ có ảnh hưởng đến trạng thái
riêng lẻ của tất cả các luồng đó. Ví dụ, nếu bản trình bày /movie
chứa hai luồng, /movie/audio và /movie/video, thì lệnh sau:

```http
PLAY rtsp://foo.com/movie RTSP/1.0
     CSeq: 559
     Session: 12345678
```

sẽ có ảnh hưởng đến các trạng thái của movie/audio và movie/video.

     Ví dụ này không hàm ý một cách thức tiêu chuẩn để biểu diễn các
     luồng trong URL hay mối liên hệ với hệ thống tệp. Xem Mục 3.2.

Các yêu cầu OPTIONS, ANNOUNCE, DESCRIBE, GET_PARAMETER,
SET_PARAMETER không có bất kỳ ảnh hưởng nào đến trạng thái của máy
khách hoặc máy chủ và do đó không được liệt kê trong các bảng trạng
thái.

### A.1 Máy trạng thái máy khách (Client State Machine)

Máy khách có thể đảm nhận các trạng thái sau:

- **Init:**
  SETUP đã được gửi, đang chờ phản hồi.

- **Ready:**
  Đã nhận được phản hồi SETUP hoặc đã nhận được phản hồi PAUSE
  khi đang ở trạng thái Playing.

- **Playing:**
  Đã nhận được phản hồi PLAY.

- **Recording:**
  Đã nhận được phản hồi RECORD.

Nhìn chung, máy khách thay đổi trạng thái khi nhận được phản hồi cho
các yêu cầu. Lưu ý rằng một số yêu cầu có hiệu lực tại một thời điểm
hoặc vị trí trong tương lai (chẳng hạn như PAUSE), và trạng thái cũng
thay đổi tương ứng. Nếu không yêu cầu SETUP tường minh cho đối tượng
(ví dụ: đối tượng

khả dụng qua một nhóm multicast), trạng thái bắt đầu ở Ready. Trong
trường hợp này, chỉ có hai trạng thái là Ready và Playing. Máy khách
cũng thay đổi trạng thái từ Playing/Recording sang Ready khi đạt đến
điểm cuối của khoảng giá trị (range) được yêu cầu.

Cột "trạng thái tiếp theo" chỉ định trạng thái đạt được sau khi nhận
được một phản hồi thành công (2xx). Nếu một yêu cầu mang lại mã trạng
thái 3xx, trạng thái sẽ trở thành Init, và mã trạng thái 4xx sẽ không
làm thay đổi trạng thái. Các thông điệp không được liệt kê cho từng
trạng thái KHÔNG ĐƯỢC (MUST NOT) gửi bởi máy khách ở trạng thái đó,
ngoại trừ các thông điệp không ảnh hưởng đến trạng thái như đã liệt
kê ở trên. Nhận được một REDIRECT từ máy chủ tương đương với việc
nhận được một trạng thái chuyển hướng 3xx từ máy chủ.

| Trạng thái (State) | Thông điệp gửi (Message Sent) | Trạng thái tiếp theo sau phản hồi (Next State) |
| :--- | :--- | :--- |
| Init | SETUP | Ready |
| | TEARDOWN | Init |
| Ready | PLAY | Playing |
| | RECORD | Recording |
| | TEARDOWN | Init |
| | SETUP | Ready |
| Playing | PAUSE | Ready |
| | TEARDOWN | Init |
| | PLAY | Playing |
| | SETUP | Playing (thay đổi transport) |
| Recording | PAUSE | Ready |
| | TEARDOWN | Init |
| | RECORD | Recording |
| | SETUP | Recording (thay đổi transport) |

### A.2 Máy trạng thái máy chủ (Server State Machine)

Máy chủ có thể đảm nhận các trạng thái sau:

- **Init:**
  Trạng thái ban đầu, chưa nhận được SETUP hợp lệ nào.

- **Ready:**
  Yêu cầu SETUP nhận được gần nhất đã thành công, phản hồi đã
  được gửi, hoặc sau khi phát, yêu cầu PAUSE nhận được gần nhất
  đã thành công, phản hồi đã được gửi.

- **Playing:**
  Yêu cầu PLAY nhận được gần nhất đã thành công, phản hồi đã
  được gửi. Dữ liệu đang được truyền đi.

- **Recording:**
  Máy chủ đang ghi dữ liệu phương tiện.

Nhìn chung, máy chủ thay đổi trạng thái khi nhận được các yêu cầu.
Nếu máy chủ đang ở trạng thái Playing hoặc Recording và ở chế độ
unicast, nó CÓ THỂ (MAY) quay về Init và hủy bỏ phiên RTSP nếu không
nhận được thông tin "hoạt động tốt" (wellness), chẳng hạn như các báo
cáo RTCP hoặc các lệnh RTSP từ máy khách trong một khoảng thời gian
xác định, với mặc định là một phút. Máy chủ có thể khai báo một giá
trị thời gian chờ (timeout) khác trong tiêu đề phản hồi Session (Mục
12.37). Nếu máy chủ đang ở trạng thái Ready, nó CÓ THỂ (MAY) quay về
Init nếu không nhận được yêu cầu RTSP nào trong một khoảng thời gian
hơn một phút. Lưu ý rằng một số yêu cầu (chẳng hạn như PAUSE) có thể
có hiệu lực tại một thời điểm hoặc vị trí trong tương lai, và trạng
thái máy chủ sẽ thay đổi vào thời điểm thích hợp. Máy chủ quay về từ
trạng thái Playing hoặc Recording sang trạng thái Ready khi kết thúc
khoảng giá trị được yêu cầu bởi máy khách.

Thông điệp REDIRECT, khi được gửi, có hiệu lực ngay lập tức trừ khi
nó có tiêu đề Range chỉ định thời điểm chuyển hướng có hiệu lực.
Trong trường hợp đó, trạng thái máy chủ cũng sẽ thay đổi vào thời
điểm thích hợp.

Nếu không yêu cầu SETUP tường minh cho đối tượng, trạng thái bắt đầu
ở Ready và chỉ có hai trạng thái là Ready và Playing.

Cột "trạng thái tiếp theo" chỉ định trạng thái đạt được sau khi gửi
một phản hồi thành công (2xx). Nếu một yêu cầu dẫn đến mã trạng thái
3xx, trạng thái sẽ trở thành Init. Mã trạng thái 4xx dẫn đến việc
không thay đổi trạng thái.

     | Trạng thái (State) | Thông điệp nhận (Message Received) | Trạng thái tiếp theo (Next State) |
| :--- | :--- | :--- |
| Init | SETUP | Ready |
| | TEARDOWN | Init |
| Ready | PLAY | Playing |
| | SETUP | Ready |
| | TEARDOWN | Init |
| | RECORD | Recording |
| Playing | PLAY | Playing |
| | PAUSE | Ready |
| | TEARDOWN | Init |
| | SETUP | Playing |
| Recording | RECORD | Recording |
| | PAUSE | Ready |
| | TEARDOWN | Init |
| | SETUP | Recording |

## Phụ lục B: Tương tác với RTP (Interaction with RTP)

RTSP cho phép các máy khách phương tiện điều khiển các phần được lựa
chọn, không liền kề của các bản trình bày phương tiện, kết xuất các
luồng đó bằng một tầng phương tiện RTP [24]. Tầng phương tiện kết
xuất luồng RTP không nên bị ảnh hưởng bởi những bước nhảy trong NPT.
Do đó, cả số thứ tự RTP (RTP sequence numbers) và dấu thời gian RTP
(RTP timestamps) PHẢI (MUST) liên tục và đơn điệu qua các bước nhảy
của NPT.

Ví dụ, giả sử tần số đồng hồ là 8000 Hz, khoảng thời gian đóng gói
gói tin là 100 ms cùng số thứ tự và dấu thời gian ban đầu bằng 0. Đầu
tiên, chúng ta phát NPT từ 10 đến 15, sau đó nhảy cóc và phát NPT từ
18 đến 20. Đoạn đầu tiên được thể hiện dưới dạng các gói RTP có số thứ
tự từ 0 đến 49 và dấu thời gian từ 0 đến 39.200. Đoạn thứ hai bao gồm
các gói RTP có số thứ tự từ 50 đến 69, với dấu thời gian từ 40.000 đến
55.200.

     Chúng ta không thể giả định rằng máy khách RTSP có thể giao tiếp
     với tác nhân phương tiện RTP, vì hai bên có thể là các tiến trình
     độc lập. Nếu dấu thời gian RTP thể hiện cùng một khoảng trống như
     NPT, tác nhân phương tiện sẽ cho rằng có sự tạm dừng trong bản
     trình bày. Nếu bước nhảy trong NPT đủ lớn, dấu thời gian RTP có thể
     bị tràn vòng (roll over) và tác nhân phương tiện có thể coi các gói
     tin sau đó là bản sao của các gói tin vừa phát xong.

     Đối với một số kiểu dữ liệu nhất định, việc tích hợp chặt chẽ giữa
     tầng RTSP và tầng RTP sẽ là cần thiết. Điều này hoàn toàn không loại
     trừ hạn chế nêu trên. Các máy khách phương tiện kết hợp RTSP/RTP nên
     sử dụng trường RTP-Info để xác định xem các gói RTP gửi đến được gửi
     trước hay sau thao tác tua tìm (seek).

Đối với âm thanh liên tục, máy chủ NÊN (SHOULD) đặt bit đánh dấu RTP
(RTP marker bit) ở đầu khi bắt đầu phục vụ một yêu cầu PLAY mới. Điều
này cho phép máy khách thực hiện việc điều chỉnh độ trễ phát lại
(playout delay adaptation).

Đối với thay đổi tỷ lệ (xem Mục 12.34), dấu thời gian RTP nên tương
ứng với thời gian phát lại. Ví dụ, khi phát video được ghi ở tốc độ
30 khung hình/giây với tỷ lệ scale là 2 và tốc độ (Mục 12.35) là 1,
máy chủ sẽ bỏ qua mỗi khung hình thứ hai để duy trì và phân phối các
gói video với khoảng cách dấu thời gian bình thường là 3.000 cho mỗi
khung hình, nhưng NPT sẽ tăng thêm 1/15 giây cho mỗi khung hình video.

Máy khách có thể duy trì việc hiển thị NPT chính xác bằng cách ghi
nhận giá trị dấu thời gian RTP của gói tin đầu tiên đến sau khi định vị
lại. Tham số sequence của tiêu đề RTP-Info (Mục 12.33) cung cấp số
thứ tự đầu tiên của đoạn tiếp theo.

## Phụ lục C: Sử dụng SDP cho mô tả phiên RTSP

Giao thức Mô tả Phiên (SDP, RFC 2327 [6]) có thể được sử dụng để
mô tả các luồng hoặc các bản trình bày trong RTSP. Việc sử dụng như
vậy được giới hạn trong việc chỉ định các phương tiện truy cập và
(các) cơ chế mã hóa cho:

- **điều khiển tổng hợp (aggregate control):**
  Một bản trình bày bao gồm các luồng từ một hoặc nhiều máy chủ
  mà không khả dụng cho việc điều khiển tổng hợp. Một mô tả như
  vậy thường được lấy về bằng HTTP hoặc các phương tiện phi RTSP
  khác. Tuy nhiên, chúng có thể được nhận bằng các phương thức
  ANNOUNCE.

- **điều khiển không tổng hợp (non-aggregate control):**
  Một bản trình bày bao gồm nhiều luồng từ một máy chủ duy nhất
  mà khả dụng cho việc điều khiển tổng hợp. Một mô tả như vậy
  thường được trả về trong phản hồi cho một yêu cầu DESCRIBE trên
  một URL, hoặc nhận được trong một phương thức ANNOUNCE.

Phụ lục này mô tả cách một tệp SDP, ví dụ được truy xuất qua HTTP,
xác định hoạt động của một phiên RTSP. Nó cũng mô tả cách một máy
khách nên thông dịch nội dung SDP được trả về trong phản hồi cho một
yêu cầu DESCRIBE. SDP không cung cấp cơ chế nào để máy khách có thể
phân biệt, nếu không có sự hướng dẫn của con người, giữa nhiều luồng
phương tiện được kết xuất đồng thời và một tập hợp các lựa chọn thay
thế (ví dụ: hai luồng âm thanh được nói bằng các ngôn ngữ khác nhau).

### C.1 Các định nghĩa (Definitions)

Các thuật ngữ "cấp độ phiên" (session-level), "cấp độ phương tiện"
(media-level) và các tên/giá trị khóa/thuộc tính khác được sử dụng
trong phụ lục này phải được sử dụng như đã định nghĩa trong SDP
(RFC 2327 [6]):

#### C.1.1 URL điều khiển (Control URL)

Thuộc tính "a=control:" được sử dụng để truyền tải URL điều khiển.
Thuộc tính này được dùng cho cả mô tả phiên và mô tả phương tiện. Nếu
được dùng cho phương tiện riêng lẻ, nó chỉ định URL sẽ được sử dụng để
điều khiển luồng phương tiện cụ thể đó. Nếu tìm thấy ở cấp độ phiên,
thuộc tính này chỉ định URL dùng cho điều khiển tổng hợp.

Ví dụ:
     a=control:rtsp://example.com/foo

Thuộc tính này có thể chứa URL tương đối hoặc tuyệt đối, tuân theo
các quy tắc và quy ước được nêu trong RFC 1808 [25]. Các bản triển
khai nên tìm kiếm URL cơ sở theo thứ tự sau:

1.     Trường RTSP Content-Base
2.     Trường RTSP Content-Location
3.     URL của yêu cầu RTSP (RTSP request URL)

Nếu thuộc tính này chỉ chứa một dấu hoa thị (*), thì URL sẽ được xử
lý như thể nó là một URL nhúng trống, và do đó kế thừa toàn bộ URL cơ
sở.

#### C.1.2 Các luồng phương tiện (Media streams)

Trường "m=" được sử dụng để liệt kê các luồng. Dự kiến rằng tất cả
các luồng được chỉ định sẽ được kết xuất với sự đồng bộ thích hợp.
Nếu phiên là unicast, số hiệu cổng đóng vai trò là một khuyến nghị
từ máy chủ cho máy khách; máy khách vẫn phải đưa nó vào yêu cầu SETUP
của mình và có thể bỏ qua khuyến nghị này. Nếu máy chủ không có ưu
tiên, nó NÊN (SHOULD) đặt giá trị số hiệu cổng bằng 0.

Ví dụ:
     m=audio 0 RTP/AVP 31

#### C.1.3 (Các) kiểu tải trọng (Payload type(s))

(Các) kiểu tải trọng được chỉ định trong trường "m=". Trong trường hợp
kiểu tải trọng là một kiểu tải trọng tĩnh từ RFC 1890 [1], không cần
thông tin nào khác. Trong trường hợp nó là một kiểu tải trọng động,
thuộc tính phương tiện "rtpmap" được sử dụng để chỉ định phương tiện
đó là gì. "Tên mã hóa" (encoding name) bên trong thuộc tính "rtpmap"
có thể là một trong những tên được chỉ định trong RFC 1890 (Mục 5 và
6), hoặc một mã hóa thử nghiệm với tiền tố "X-" như được chỉ định
trong SDP (RFC 2327 [6]). Các tham số riêng của codec không được chỉ
định trong trường này, mà được chỉ định trong thuộc tính "fmtp" được
mô tả dưới đây. Các nhà triển khai muốn đăng ký các mã hóa mới nên
tuân theo quy trình trong RFC 1890 [1]. Nếu kiểu phương tiện không phù
hợp với hồ sơ RTP AV, thì khuyến nghị nên tạo một hồ sơ mới và tên hồ
sơ thích hợp sẽ được sử dụng thay cho "RTP/AVP" trong trường "m=".

#### C.1.4 Các tham số riêng cho định dạng (Format-specific parameters)

Các tham số riêng cho định dạng được truyền tải bằng thuộc tính
phương tiện "fmtp". Cú pháp của thuộc tính "fmtp" phụ thuộc vào (các)
mã hóa mà thuộc tính đó tham chiếu tới. Lưu ý rằng khoảng thời gian
đóng gói gói tin được truyền tải bằng thuộc tính "ptime".

#### C.1.5 Khoảng giá trị của bản trình bày (Range of presentation)

Thuộc tính "a=range" xác định tổng khoảng thời gian của phiên được
lưu trữ. (Độ dài của các phiên trực tiếp có thể được suy ra từ các
tham số "t" và "r".) Trừ khi bản trình bày chứa các luồng phương tiện
có thời lượng khác nhau, thuộc tính range là thuộc tính ở cấp độ
phiên. Đơn vị được chỉ định trước, tiếp theo là khoảng giá trị. Các
đơn vị và giá trị của chúng như đã được định nghĩa trong Mục 3.5, 3.6
và 3.7.

Ví dụ:
     a=range:npt=0-34.4368
     a=range:clock=19971113T2115-19971113T2203

#### C.1.6 Thời gian khả dụng (Time of availability)

Trường "t=" PHẢI (MUST) chứa các giá trị phù hợp cho thời gian bắt
đầu và kết thúc cho cả việc điều khiển luồng tổng hợp và không tổng
hợp. Với điều khiển tổng hợp, máy chủ NÊN (SHOULD) chỉ định một giá
trị thời gian kết thúc mà tại đó máy chủ đảm bảo phần mô tả là hợp lệ,
và thời gian bắt đầu bằng hoặc trước thời điểm nhận được yêu cầu
DESCRIBE. Nó cũng CÓ THỂ (MAY) chỉ định thời gian bắt đầu và kết thúc
bằng 0, có nghĩa là phiên luôn khả dụng. Với điều khiển không tổng
hợp, các giá trị phải phản ánh khoảng thời gian thực tế mà phiên khả
dụng theo ngữ nghĩa SDP, và không phụ thuộc vào các phương tiện khác
(chẳng hạn như vòng đời của trang web chứa phần mô tả) cho mục đích
này.

#### C.1.7 Thông tin kết nối (Connection Information)

Trong SDP, trường "c=" chứa địa chỉ đích cho luồng phương tiện. Tuy
nhiên, đối với các luồng unicast theo yêu cầu và một số luồng
multicast, địa chỉ đích được máy khách chỉ định thông qua yêu cầu
SETUP. Trừ khi nội dung phương tiện có địa chỉ đích cố định, trường
"c=" phải được đặt thành một giá trị rỗng (null value) phù hợp. Đối
với các địa chỉ thuộc loại "IP4", giá trị này là "0.0.0.0".

#### C.1.8 Thẻ thực thể (Entity Tag)

Thuộc tính tùy chọn "a=etag" xác định một phiên bản của mô tả phiên.
Nó là không trong suốt đối với máy khách. Các yêu cầu SETUP có thể bao
gồm mã định danh này trong trường If-Match (xem Mục 12.22) để chỉ cho
phép thiết lập phiên nếu giá trị thuộc tính này vẫn tương ứng với giá
trị của bản mô tả hiện tại. Giá trị thuộc tính là không trong suốt và
có thể chứa bất kỳ ký tự nào được cho phép trong các giá trị thuộc
tính SDP.

Ví dụ:
     a=etag:158bb3e7c7fd62ce67f12b533f06b83a

Có thể lập luận rằng trường "o=" cung cấp chức năng tương tự. Tuy
     nhiên, nó làm như vậy theo cách đặt ra những hạn chế đối với các
     máy chủ cần hỗ trợ nhiều kiểu mô tả phiên khác ngoài SDP cho cùng
     một nội dung phương tiện.

### C.2 Không khả dụng điều khiển tổng hợp (Aggregate Control Not Available)

Nếu một bản trình bày không hỗ trợ điều khiển tổng hợp và nhiều phần
phương tiện được chỉ định, mỗi phần PHẢI (MUST) có URL điều khiển
được chỉ định thông qua thuộc tính "a=control:".

Ví dụ:
     
```sdp
v=0
o=- 2890844256 2890842807 IN IP4 204.34.34.32
s=I came from a web page
t=0 0
c=IN IP4 0.0.0.0
m=video 8002 RTP/AVP 31
a=control:rtsp://audio.com/movie.aud
m=audio 8004 RTP/AVP 3
a=control:rtsp://video.com/movie.vid
```

Lưu ý rằng vị trí của URL điều khiển trong phần mô tả hàm ý rằng máy
khách thiết lập các phiên điều khiển RTSP riêng biệt tới các máy chủ
audio.com và video.com.

Khuyến nghị rằng một tệp SDP nên chứa thông tin khởi tạo phương tiện
hoàn chỉnh ngay cả khi nó được phân phối tới máy khách phương tiện
thông qua các phương tiện phi RTSP. Điều này là cần thiết vì không có
cơ chế nào để chỉ ra rằng máy khách nên yêu cầu thông tin luồng
phương tiện chi tiết hơn qua DESCRIBE.

### C.3 Khả dụng điều khiển tổng hợp (Aggregate Control Available)

Trong kịch bản này, máy chủ có nhiều luồng có thể được điều khiển như
một thể thống nhất. Trong trường hợp này, có cả các thuộc tính
"a=control:" ở cấp độ phương tiện, được sử dụng để chỉ định các URL
của luồng, và một thuộc tính "a=control:" ở cấp độ phiên được sử dụng
làm URL yêu cầu cho điều khiển tổng hợp. Nếu URL cấp độ phương tiện là
tương đối, nó sẽ được phân giải thành các URL tuyệt đối theo Mục C.1.1
ở trên.

Nếu bản trình bày chỉ bao gồm một luồng duy nhất, thuộc tính
"a=control:" ở cấp độ phương tiện có thể được bỏ qua hoàn toàn. Tuy
nhiên, nếu bản trình bày chứa nhiều hơn một luồng, mỗi phần luồng
phương tiện PHẢI (MUST) chứa thuộc tính "a=control" của riêng nó.

Ví dụ:
     
```sdp
v=0
o=- 2890844256 2890842807 IN IP4 204.34.34.32
s=I contain
i=<more info>
t=0 0
c=IN IP4 0.0.0.0
a=control:rtsp://example.com/movie/
m=video 8002 RTP/AVP 31
a=control:trackID=1
m=audio 8004 RTP/AVP 3
a=control:trackID=2
```

Trong ví dụ này, máy khách được yêu cầu thiết lập một phiên RTSP duy
nhất tới máy chủ, và sử dụng các URL
rtsp://example.com/movie/trackID=1 và
rtsp://example.com/movie/trackID=2 để thiết lập tương ứng các luồng
video và âm thanh. URL rtsp://example.com/movie/ điều khiển toàn bộ
bộ phim.

## Phụ lục D: Triển khai RTSP tối thiểu (Minimal RTSP Implementation)

### D.1 Máy khách (Client)

Một bản triển khai máy khách PHẢI (MUST) có khả năng thực hiện những
điều sau:

- Tạo các yêu cầu sau: SETUP, TEARDOWN, và một trong hai yêu cầu
       PLAY (tức là một máy khách phát lại tối thiểu) hoặc RECORD (tức là
       một máy khách ghi tối thiểu). Nếu RECORD được triển khai,
       ANNOUNCE cũng phải được triển khai.
- Bao gồm các tiêu đề sau trong các yêu cầu: CSeq, Connection,
       Session, Transport. Nếu ANNOUNCE được triển khai, khả năng bao
       gồm các tiêu đề Content-Language, Content-Encoding, Content-
       Length và Content-Type cũng phải có.
- Phân tích cú pháp và hiểu các tiêu đề sau trong các phản hồi: CSeq,
       Connection, Session, Transport, Content-Language, Content-
       Encoding, Content-Length, Content-Type. Nếu RECORD được triển
       khai, tiêu đề Location cũng phải được hiểu. Các bản triển khai
       tuân thủ RTP cũng nên triển khai RTP-Info.
- Hiểu lớp của từng mã lỗi nhận được và thông báo cho người dùng
       cuối, nếu có người dùng cuối, về các mã lỗi thuộc các lớp 4xx và
       5xx. Yêu cầu thông báo có thể được nới lỏng nếu người dùng cuối chỉ
       định rõ ràng là không muốn nhận nó cho một hoặc tất cả các mã trạng
       thái.
- Dự kiến và phản hồi các yêu cầu bất đồng bộ từ máy chủ, chẳng hạn
       như ANNOUNCE. Điều này không nhất thiết có nghĩa là nó phải triển
       khai phương thức ANNOUNCE, mà chỉ đơn thuần là nó PHẢI (MUST) phản
       hồi khẳng định hoặc phủ định đối với bất kỳ yêu cầu nào nhận được
       từ máy chủ.

Mặc dù không bắt buộc, những điều sau đây rất được khuyến nghị tại
thời điểm công bố để có khả năng tương tác thực tế với các bản triển
khai ban đầu và/hoặc để trở thành một "công dân tốt" (good citizen):

- Triển khai RTP/AVP/UDP như một giao thức truyền tải hợp lệ.
- Bao gồm tiêu đề User-Agent.
- Hiểu các mô tả phiên SDP như được định nghĩa trong Phụ lục C.
- Chấp nhận các định dạng khởi tạo phương tiện (chẳng hạn như SDP)
       từ đầu vào tiêu chuẩn, dòng lệnh hoặc các phương tiện khác phù
       hợp với môi trường điều hành để hoạt động như một "ứng dụng trợ
       giúp" (helper application) cho các ứng dụng khác (chẳng hạn như
       trình duyệt web).

     Có thể có các ứng dụng RTSP khác với những gì được dự tính ban đầu
     bởi những người đóng góp vào đặc tả RTSP mà các yêu cầu trên không
     hợp lý. Do đó, các khuyến nghị trên chỉ đóng vai trò là hướng dẫn
     chứ không phải là các yêu cầu nghiêm ngặt.

#### D.1.1 Phát lại cơ bản (Basic Playback)

Để hỗ trợ phát lại các luồng phương tiện theo yêu cầu, máy khách PHẢI
(MUST) có thêm khả năng thực hiện những việc sau:
- tạo yêu cầu PAUSE;
- triển khai phương thức REDIRECT, và tiêu đề Location.

#### D.1.2 Đã kích hoạt xác thực (Authentication-enabled)

Để truy cập các bản trình bày phương tiện từ các máy chủ RTSP yêu cầu
xác thực, máy khách PHẢI (MUST) có thêm khả năng thực hiện những việc
sau:
- nhận biết mã trạng thái 401;
- phân tích cú pháp và bao gồm tiêu đề WWW-Authenticate;
- triển khai Xác thực cơ bản (Basic Authentication) và Xác thực
       Digest (Digest Authentication).

### D.2 Máy chủ (Server)

Một bản triển khai máy chủ tối thiểu PHẢI (MUST) có khả năng thực
hiện các điều sau:

- Triển khai các phương thức sau: SETUP, TEARDOWN, OPTIONS và một
       trong hai phương thức PLAY (cho máy chủ phát lại tối thiểu) hoặc
       RECORD (cho máy chủ ghi tối thiểu). Nếu RECORD được triển khai,
       ANNOUNCE cũng nên được triển khai.
- Bao gồm các tiêu đề sau trong các phản hồi: Connection,
       Content-Length, Content-Type, Content-Language, Content-Encoding,
       Transport, Public. Khả năng bao gồm tiêu đề Location nên được
       triển khai nếu có phương thức RECORD. Các bản triển khai tuân thủ
       RTP cũng nên triển khai trường RTP-Info.
- Phân tích cú pháp và phản hồi thích hợp với các tiêu đề sau trong
       các yêu cầu: Connection, Session, Transport, Require.

Mặc dù không bắt buộc, những điều sau đây rất được khuyến nghị tại
thời điểm công bố để có khả năng tương tác thực tế với các bản triển
khai ban đầu và/hoặc để trở thành một "công dân tốt" (good citizen):

- Triển khai RTP/AVP/UDP như một giao thức truyền tải hợp lệ.
- Bao gồm tiêu đề Server.
- Triển khai phương thức DESCRIBE.
- Tạo các mô tả phiên SDP như được định nghĩa trong Phụ lục C.

     Có thể có các ứng dụng RTSP khác với những gì được dự tính ban đầu
     bởi những người đóng góp vào đặc tả RTSP mà các yêu cầu trên không
     hợp lý. Do đó, các khuyến nghị trên chỉ đóng vai trò là hướng dẫn
     chứ không phải là các yêu cầu nghiêm ngặt.

#### D.2.1 Phát lại cơ bản (Basic Playback)

Để hỗ trợ phát lại các luồng phương tiện theo yêu cầu, máy chủ PHẢI
(MUST) có thêm khả năng thực hiện những việc sau:

- Nhận biết tiêu đề Range, và trả về lỗi nếu thao tác tua tìm
       (seeking) không được hỗ trợ.
- Triển khai phương thức PAUSE.

Ngoài ra, để hỗ trợ các tính năng giao diện người dùng thường được
chấp nhận, những điều sau đây rất được khuyến nghị cho các máy chủ
phương tiện theo yêu cầu:

- Bao gồm và phân tích cú pháp tiêu đề Range, với các đơn vị NPT.
       Việc triển khai các đơn vị SMPTE được khuyến nghị.
- Bao gồm độ dài của bản trình bày phương tiện trong thông tin khởi
       tạo phương tiện.
- Bao gồm các ánh xạ từ dấu thời gian riêng của dữ liệu sang NPT.
       Khi sử dụng RTP, phần rtptime của trường RTP-Info có thể được sử
       dụng để ánh xạ dấu thời gian RTP sang NPT.

     Các bản triển khai máy khách có thể sử dụng sự hiện diện của thông
     tin độ dài để xác định xem clip có thể tua tìm được hay không, và
     vô hiệu hóa một cách trực quan các tính năng tua tìm đối với các clip
     mà thông tin độ dài không khả dụng. Một cách sử dụng phổ biến của
     độ dài bản trình bày là triển khai một "thanh trượt" (slider bar)
     vừa đóng vai trò là chỉ báo tiến độ vừa là công cụ định vị theo
     dòng thời gian.

     Các ánh xạ từ dấu thời gian RTP sang NPT là cần thiết để đảm bảo
     việc định vị chính xác của thanh trượt.

#### D.2.2 Đã kích hoạt xác thực (Authentication-enabled)

Để xử lý chính xác việc xác thực máy khách, máy chủ PHẢI (MUST) có
thêm khả năng thực hiện những việc sau:

- Tạo mã trạng thái 401 khi tài nguyên yêu cầu xác thực.
- Phân tích cú pháp và bao gồm tiêu đề WWW-Authenticate.
- Triển khai Xác thực cơ bản (Basic Authentication) và Xác thực
       Digest (Digest Authentication).
