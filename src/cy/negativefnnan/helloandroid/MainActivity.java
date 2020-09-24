package cy.negativefnnan.helloandroid;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import android.widget.Button;

public class MainActivity extends Activity {
   @Override
   protected void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      setContentView(R.layout.activity_main);

      final Button button = (Button) findViewById(R.id.hello_button);
      final TextView textView = (TextView) findViewById(R.id.hello_text_view);
      button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View view) {
                textView.setText(R.string.hello_text);
            }
      });
   }
}
