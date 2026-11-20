package my.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

// 관리자 상품 사진 업로드 도우미
// 1) cos MultipartRequest로 임시 폴더에 받는다 (웹 폴더에 바로 저장하지 않음 → jsp 같은 파일이 실행될 틈이 없다)
// 2) 확장자와 파일 내용이 사진인지 확인한 뒤 서버의 images/products 폴더로 옮긴다
// 3) 프로젝트 원본 폴더에도 복사해 둔다
public class UploadUtil {

	// 프로젝트 원본 폴더의 상품 사진 위치 (PC마다 자동으로 찾는다 → 팀원끼리 이 줄을 고칠 필요 없음)
	// 1) 환경변수 CAMPMALL_IMAGE_DIR 이 있으면 그 경로
	// 2) 없으면 내 PC의 eclipse-workspace 안에서 campmall 또는 termproject 프로젝트를 찾음
	public static final String PROJECT_PRODUCT_IMAGE_DIR = findProjectImageDir();

	private static String findProjectImageDir() {
		String env = System.getenv("CAMPMALL_IMAGE_DIR");
		if (env != null && !env.trim().isEmpty()) return env.trim();
		File workspace = new File(System.getProperty("user.home"), "eclipse-workspace");
		for (String project : new String[] {"campmall", "termproject"}) {
			File dir = new File(workspace, project + File.separator + "WebContents"
					+ File.separator + "images" + File.separator + "products");
			if (dir.isDirectory()) return dir.getPath();
		}
		return new File(workspace, "campmall" + File.separator + "WebContents"
				+ File.separator + "images" + File.separator + "products").getPath();
	}

	// 올릴 수 있는 사진 크기 (5MB)
	public static final int MAX_SIZE = 5 * 1024 * 1024;

	// 사진 확장자만 허용 (png, jpg, gif, webp)
	public static boolean isImage(String fileName) {
		if (fileName == null) return false;
		String name = fileName.toLowerCase();
		return name.endsWith(".png") || name.endsWith(".jpg") || name.endsWith(".jpeg")
				|| name.endsWith(".gif") || name.endsWith(".webp");
	}

	// 파일 앞부분(시그니처)이 실제 사진 형식인지 확인 (확장자만 바꾼 파일 차단)
	public static boolean isImageContent(File file) {
		byte[] b = new byte[12];
		int n = 0;
		try (InputStream in = new FileInputStream(file)) {
			n = in.read(b);
		} catch (IOException e) {
			return false;
		}
		if (n < 12) return false;
		boolean png = (b[0] & 0xFF) == 0x89 && b[1] == 'P' && b[2] == 'N' && b[3] == 'G';
		boolean jpg = (b[0] & 0xFF) == 0xFF && (b[1] & 0xFF) == 0xD8 && (b[2] & 0xFF) == 0xFF;
		boolean gif = b[0] == 'G' && b[1] == 'I' && b[2] == 'F' && b[3] == '8';
		boolean webp = b[0] == 'R' && b[1] == 'I' && b[2] == 'F' && b[3] == 'F'
				&& b[8] == 'W' && b[9] == 'E' && b[10] == 'B' && b[11] == 'P';
		return png || jpg || gif || webp;
	}

	// 임시 폴더에 받은 파일을 사진 폴더(serverDir)로 옮기고 저장된 파일 이름을 돌려준다.
	// 사진이 아니면 임시 파일을 지우고 null을 돌려준다.
	public static String moveImage(File tempDir, String fileName, String serverDir) {
		if (fileName == null) return null;
		File temp = new File(tempDir, fileName);
		try {
			if (!isImage(fileName) || !isImageContent(temp)) {
				return null;
			}
			// 파일 이름에서 주소에 쓰기 어려운 글자는 _로 바꾸고, 같은 이름이 있으면 뒤에 숫자를 붙인다
			String safe = fileName.replaceAll("[^A-Za-z0-9._\\-가-힣]", "_");
			int dot = safe.lastIndexOf('.');
			String base = safe.substring(0, dot);
			String ext = safe.substring(dot).toLowerCase();
			File dir = new File(serverDir);
			dir.mkdirs();
			File to = new File(dir, base + ext);
			for (int i = 1; to.exists(); i++) {
				to = new File(dir, base + i + ext);
			}
			Files.move(temp.toPath(), to.toPath());
			copyToProject(serverDir, to.getName());
			return to.getName();
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		} finally {
			temp.delete();   // 옮기지 못한 임시 파일은 지운다
		}
	}

	// 업로드는 지금 실행 중인 서버 폴더에 저장되므로 화면에 바로 보인다.
	// 서버 폴더에만 있으면 Eclipse에서 Clean 할 때 지워지므로, 프로젝트 원본 폴더에도 복사해 둔다.
	public static void copyToProject(String serverDir, String fileName) {
		if (fileName == null) return;
		File projectDir = new File(PROJECT_PRODUCT_IMAGE_DIR);
		if (!projectDir.isDirectory()) return;   // 경로가 없는 PC면 건너뜀
		File from = new File(serverDir, fileName);
		File to = new File(projectDir, fileName);
		try {
			if (from.getCanonicalPath().equals(to.getCanonicalPath())) return;  // 같은 폴더면 복사할 필요 없음
			Files.copy(from.toPath(), to.toPath(), StandardCopyOption.REPLACE_EXISTING);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
