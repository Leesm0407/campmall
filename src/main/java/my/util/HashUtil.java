package my.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class HashUtil {

	// 비밀번호를 SHA-256 해시(64자리 16진수)로 바꾼다.
	// MySQL의 SHA2('비밀번호', 256)과 같은 값이 나온다. (seed.sql의 관리자 비밀번호와 비교 가능)
	public static String sha256(String text) {
		try {
			MessageDigest md = MessageDigest.getInstance("SHA-256");
			byte[] bytes = md.digest(text.getBytes(StandardCharsets.UTF_8));
			StringBuilder sb = new StringBuilder();
			for (byte b : bytes) {
				sb.append(String.format("%02x", b));
			}
			return sb.toString();
		} catch (NoSuchAlgorithmException e) {
			throw new RuntimeException(e);
		}
	}
}
