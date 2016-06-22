package com.liferay.mobile.screens.viewsets.defaultviews.rating;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.view.ViewParent;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.liferay.mobile.screens.R;
import com.liferay.mobile.screens.base.BaseScreenlet;
import com.liferay.mobile.screens.context.SessionContext;
import com.liferay.mobile.screens.rating.RatingEntry;
import com.liferay.mobile.screens.rating.RatingScreenlet;
import com.liferay.mobile.screens.rating.view.RatingViewModel;
import com.liferay.mobile.screens.util.LiferayLogger;
import java.util.List;

/**
 * @author Alejandro Hernández
 */
public class ThumbsRatingView extends LinearLayout implements RatingViewModel, View.OnClickListener {

  public ThumbsRatingView(Context context) {
      super(context);
  }

  public ThumbsRatingView(Context context, AttributeSet attrs) {
      super(context, attrs);
  }

  public ThumbsRatingView(Context context, AttributeSet attrs, int defStyleAttr) {
      super(context, attrs, defStyleAttr);
  }

  @Override public void showStartOperation(String actionName) {

  }

  @Override public void showFailedOperation(String actionName, Exception e) {
    switch (actionName) {
      case RatingScreenlet.LOAD_RATINGS_ACTION:
        LiferayLogger.e(getContext().getString(R.string.loading_ratings_error), e);
        break;
      case RatingScreenlet.LOAD_USER_RATING_ACTION:
        LiferayLogger.e(getContext().getString(R.string.loading_user_rating_error), e);
        break;
      case RatingScreenlet.ADD_RATING_ACTION:
        LiferayLogger.e(getContext().getString(R.string.adding_error_rating), e);
        break;
      case RatingScreenlet.UPDATE_RATING_ACTION:
        LiferayLogger.e(getContext().getString(R.string.updating_rating_error), e);
        break;
      default:
        LiferayLogger.e(getContext().getString(R.string.ratings_error), e);
        break;
    }
  }

  @Override public void showFinishOperation(String actionName) {
    throw new AssertionError("Use showFinishOperation(actionName, argument) instead");
  }

  @Override public void showFinishOperation(String action, Object argument) {
    switch (action) {
      case RatingScreenlet.LOAD_RATINGS_ACTION:
        _negativeCount = _possitiveCount = 0;
        _userRatingEntry = null;

        for (RatingEntry entry : (List<RatingEntry>) argument) {
          updateGlobalScore(entry);
        }

        break;
      case RatingScreenlet.LOAD_USER_RATING_ACTION:
        updateRatingButtons((RatingEntry) argument);
        break;
      case RatingScreenlet.ADD_RATING_ACTION:
        RatingEntry newUserEntry = (RatingEntry) argument;
        updateGlobalScore(newUserEntry);
        updateRatingButtons(newUserEntry);
        break;
      case RatingScreenlet.UPDATE_RATING_ACTION:
        RatingEntry updatedUserEntry = (RatingEntry) argument;
        double change = (updatedUserEntry.getScore() == 0) ? 1 : -1;
        _negativeCount += change;
        _possitiveCount += -change;
        updateRatingButtons(updatedUserEntry);
        break;
      default:
        break;
    }
    updateCountLabels();
  }

  private void updateGlobalScore(RatingEntry entry) {
    if (entry.getScore() == 0) {
      _negativeCount++;
    } else {
      _possitiveCount++;
    }
  }

  private void updateRatingButtons(RatingEntry userEntry) {
    _possitiveButton.setEnabled(userEntry.getScore() == 0);
    _negativeButton.setEnabled(userEntry.getScore() > 0);
  }

  private void updateCountLabels() {
    _possitiveCountLabel.setText(getContext().getString(R.string.rating_total) + Integer.toString(_possitiveCount));
    _negativeCountLabel.setText(getContext().getString(R.string.rating_total) + Integer.toString(_negativeCount));
  }

  @Override public void onClick(View v) {
    final int id = v.getId();
    if (id == R.id.positiveRatingButton && userCanClickPossitiveButton()) {
      getScreenlet().performUserAction(RatingScreenlet.ADD_RATING_ACTION, 1.0);
    } else if (id == R.id.negativeRatingButton && userCanClickNegativeButton()) {
      getScreenlet().performUserAction(RatingScreenlet.ADD_RATING_ACTION, 0.0);
    }
  }

  private boolean userCanClickPossitiveButton() {
    return _userRatingEntry == null || _userRatingEntry.getScore() == 0;
  }

  private boolean userCanClickNegativeButton() {
    return _userRatingEntry == null || _userRatingEntry.getScore() > 0;
  }

  @Override public BaseScreenlet getScreenlet() {
      return _screenlet;
  }

  @Override public void setScreenlet(BaseScreenlet screenlet) {
      _screenlet = screenlet;
  }

  @Override
  protected void onFinishInflate() {
    super.onFinishInflate();

    _negativeButton = (Button) findViewById(R.id.negativeRatingButton);
    _possitiveButton = (Button) findViewById(R.id.positiveRatingButton);

    _negativeCountLabel = (TextView) findViewById(R.id.negativeRatingCount);
    _possitiveCountLabel = (TextView) findViewById(R.id.positiveRatingCount);

    _negativeButton.setOnClickListener(this);
    _possitiveButton.setOnClickListener(this);
  }

  private Button _negativeButton;
  private Button _possitiveButton;
  private TextView _negativeCountLabel;
  private TextView _possitiveCountLabel;
  private int _negativeCount;
  private int _possitiveCount;

  private RatingEntry _userRatingEntry;

  private BaseScreenlet _screenlet;
}
