package com.liferay.mobile.screens.comment.display.interactor;

import com.liferay.mobile.screens.base.list.interactor.ListEvent;
import com.liferay.mobile.screens.comment.CommentEntry;
import org.json.JSONObject;

/**
 * @author Alejandro Hernández
 */
public class CommentEvent extends ListEvent<CommentEntry> {

	private String className;
	private long classPK;
	private long commentId;
	private String body;

	public CommentEvent() {
		super();
	}

	public CommentEvent(long commentId, String className, long classPK, String body, CommentEntry commentEntry) {
		this(commentId, className, classPK, body);
		this.commentEntry = commentEntry;
	}

	public CommentEvent(long commentId, String className, long classPK, String body) {
		this.commentId = commentId;
		this.className = className;
		this.classPK = classPK;
		this.body = body;
	}

	public CommentEvent(JSONObject jsonObject) {
		super(jsonObject);
	}

	@Override
	public String getCacheKey() {
		return String.valueOf(commentEntry.getCommentId());
	}

	@Override
	public CommentEntry getModel() {
		return commentEntry;
	}

	public CommentEntry getCommentEntry() {
		return commentEntry;
	}

	private CommentEntry commentEntry;

	public String getClassName() {
		return className;
	}

	public long getClassPK() {
		return classPK;
	}

	public long getCommentId() {
		return commentId;
	}

	public String getBody() {
		return body;
	}
}
