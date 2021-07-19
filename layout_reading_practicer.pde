import java.util.Map.Entry;
import processing.sound.*;
import static java.awt.event.KeyEvent.*; 



//// CONFIGURATION ////

/* See 'README.md' for an explanation. */

final String KEYMAP_FILE = "map.tsv";
final String AUDIO_FILES_FOLDER = "audio/";

final boolean DARK_MODE = true;

final float SCORE_CORRECT = 10;
final float SCORE_INCORRECT = -5;
final float SCORE_MINIMUM = 0;
final float SCORE_DECAY = -1;

final int PICK_SAMPLES = 10;

/**
 KEYMAP_FILE:
 The file to load the keymap from. Can be either csv or tsv.
 The file has to contain four columns:
 "character":
 
 AUDIO_FILES_FOLDER:
 Prefixed before the file names in the "audio" column of the `KEYMAP_FILE`.
 */


///////////////////////




ArrayList<String> characters = new ArrayList<String>();
ArrayList<String> readings = new ArrayList<String>();
ArrayList<String> keys = new ArrayList<String>();

float[] score;

int previous_index;
int index;

String typed_input = "";

boolean reveal_reading = false;

boolean reading_mode = false;

int total = 0;

Sound sound;

ArrayList<SoundFile> audios = new ArrayList<SoundFile>();

void setup() {
  size(640, 640);
  //fullScreen();

  Table map = loadTable("map.tsv", "header");
  for (TableRow r : map.rows()) {
    characters.add(r.getString("character"));
    readings.add(r.getString("reading"));
    keys.add(r.getString("key"));
    audios.add(new SoundFile(this, AUDIO_FILES_FOLDER + r.getString("audio") +".mp3"));
  }

  score = new float[characters.size()];
  for (int i = 0; i < score.length; i++) {
    score[i] = 0;
  }

  Table score_table = loadTable("saved_scores.csv", "header");
  if (score_table != null) {
    for (int i = 0; i < score_table.getRowCount(); i++) {
      TableRow r = score_table.getRow(i);
      String k = r.getString("Character");
      float s = r.getFloat("Score");
      int ki = characters.indexOf(k);
      if (ki >= 0) {
        score[ki] = s;
      }
    }
  } else {
    for (int i = 0; i < score.length; i++) {
      score[i] = 0;
    }
  }

  Runtime.getRuntime().addShutdownHook(new Thread() {
    public void run() {
      Table score_table = new Table();
      score_table.addColumn("Character");
      score_table.addColumn("Score");
      for (int i = 0; i < score.length; i++) {
        TableRow r = score_table.addRow();
        r.setString("Character", characters.get(i));
        r.setFloat("Score", score[i]);
      }
      saveTable(score_table, "saved_scores.csv");
    }
  }
  );

  next_character();
  previous_index = index;

  fill(0);
  //textFont(createFont("mplus-1p-regular.ttf",12));

  sound = new Sound(this);
}

void draw() {


  if (DARK_MODE) {
    background(0x22);
    if (reveal_reading) {
      fill(0xcc);
    } else {
      fill(0xff);
    }
  } else {
    background(0xff);
    if (reveal_reading) {
      fill(0x33);
    } else {
      fill(0x00);
    }
  }

  textAlign(LEFT, TOP);
  text("Total: " + total, 2, 0);

  textAlign(RIGHT, TOP);
  text(int(score[index]), width-2, 0);

  textAlign(CENTER, CENTER);
  translate(width/2-100, height/2-100);
  scale(25);
  text(characters.get(index), 0, 0);



  resetMatrix();
  translate(320, 500);
  scale(10);

  if (!reveal_reading) text(typed_input, 0, 3);

  //if (reveal_reading) {
  //  resetMatrix();
  //  translate(320, 500);
  //  scale(10);
  //  text(readings.get(index), 0, 3);
  //}

  if (!reveal_reading) {
    score[index]-=deltatime();
    if (score[index] < SCORE_MINIMUM) {
      score[index] = SCORE_MINIMUM;
    }
  }
}

void keyPressed() {

  if (key == '\b') {
    if (typed_input.length() > 0) {
      typed_input = typed_input.substring(0, typed_input.length()-1);
    }
  } else if (key == '\t') {
    audios.get(index).play();
  } else if (key == CODED && keyCode == VK_F1) {
    reading_mode = !reading_mode;
  } else {
    if (reading_mode) {
      if (!reveal_reading) {
        check_typed(typed_input);
      } else if (key == ' ') {
        reveal_reading();
        check_typed("");
      }
    } else {
      if (!reveal_reading) {
        check_typed(str(key));
      } else if (str(key).equals(keys.get(index))) {
        next_character();
      } else if (!reveal_reading) {
        reveal_reading();
        check_typed("");
      } else {
        play_by_key(str(key));
      }
    }
  }
}
}


void play_by_key(String k) {
  int i = keys.indexOf(k);
  if (i >= 0) {
    audios.get(i).play();
  }
}

void reveal_reading() {
  reveal_reading = true;
  audios.get(index).play();
}

void next_character() {
  previous_index = index;
  while (index == previous_index) {
    index = weighted_pick();
  }
  typed_input = "";
  reveal_reading = false;
  total++;

  for (int i = 0; i < score.length; i++) {
    if (i != previous_index) {
      score[i]-=SCORE_DECAY;
    }
  }
}

int weighted_pick() {
  int pick = int(random(0, score.length));
  for (int unu = 0; unu < PICK_SAMPLES; unu++) {
    int p = int(random(0, score.length));
    if (score[p] == 0 || score[p] < score[pick]) pick = p;
  }
  return pick;
}

void check_typed(String input) {
  println(input);
  if (input.equals(keys.get(index))) {
    score[index]+=SCORE_CORRECT;
    //next_character();
    reveal_reading();
  } else {
    score[index]+=SCORE_INCORRECT;
  }
}

int prev_time = 0;
float deltatime() {
  int dt = millis() - prev_time;
  prev_time += dt;
  return dt/1000.0;
}
